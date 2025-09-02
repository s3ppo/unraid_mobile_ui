class Subscriptions {

  static const String getCpuMetrics = r'''
    subscription {
      systemMetricsCpu {
        id
        percentTotal
      }
    }
  ''';

}