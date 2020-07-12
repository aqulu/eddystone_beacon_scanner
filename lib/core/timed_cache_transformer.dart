import 'dart:async';
import 'dart:collection';

import 'package:rxdart/rxdart.dart';

extension TimedCacheExtension<T> on Stream<T> {
  ///
  /// adds emitted events to a queue and keeps them for the specified cache lifetime.
  ///
  /// values that have not outlived the cache lifetime are accumulated and emitted
  /// on every new event and every [cacheLifetime] / 2 (internal timer event for discarding old values)
  ///
  ///
  /// if [shouldPreventDuplicates] is true, cached events will be omitted in
  /// favor of their equal new event
  ///
  Stream<List<T>> cacheFor(
    Duration cacheLifetime, {
    bool shouldPreventDuplicates = false,
  }) =>
      transform(
        _TimedCacheTransformer(
          cacheLifetime,
          shouldPreventDuplicates: shouldPreventDuplicates,
        ),
      );
}

class _TimedCacheTransformer<T> extends StreamTransformerBase<T, List<T>> {
  final Duration cacheLifetime;
  final bool shouldPreventDuplicates;

  const _TimedCacheTransformer(
    this.cacheLifetime, {
    this.shouldPreventDuplicates = false,
  });

  @override
  Stream<List<T>> bind(Stream<T> stream) {
    StreamController<List<T>> controller;
    StreamSubscription<Timestamped<T>> subscription;

    controller = StreamController<List<T>>(
      sync: true,
      onListen: () {
        final queue = Queue<Timestamped<T>>();
        final emit = () {
          controller.add(List.unmodifiable(queue.map((it) => it.value)));
        };

        // timer to periodically update emitted value and clean the queue
        final timer = Timer.periodic(cacheLifetime ~/ 2, (_) {
          queue.retainWhere(_isInCacheLifetime);
          emit();
        });

        final onData = (Timestamped<T> event) {
          queue
            ..retainWhere(_isInCacheLifetime)
            ..retainWhere(
              (it) => !shouldPreventDuplicates || it.value != event.value,
            )
            ..add(event);
          emit();
        };

        final onDone = () {
          timer.cancel();
          queue.clear();
          controller.close();
        };

        subscription = stream
            .timestamp()
            .listen(onData, onError: controller.addError, onDone: onDone);
      },
      onPause: ([Future resumeSignal]) {
        subscription?.pause(resumeSignal);
      },
      onResume: () {
        subscription?.resume();
      },
      onCancel: () {
        return subscription?.cancel();
      },
    );

    return controller.stream;
  }

  /// returns a predicate that checks whether or not a [Timestamped] event
  /// has outlived [cacheLifetime]
  bool Function(Timestamped<dynamic>) get _isInCacheLifetime {
    final now = DateTime.now();
    return (Timestamped<dynamic> event) =>
        now.difference(event.timestamp).abs() < cacheLifetime;
  }
}
