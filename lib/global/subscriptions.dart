class Subscriptions {

  static const String getCpuMetrics = r'''
subscription SystemMetricsCpu {
  systemMetricsCpu {
    id
    percentTotal
  }
}
  ''';

}