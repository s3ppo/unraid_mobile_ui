class Mutations {
  static const String stopDocker = r'''
            query StopContainer($containerId: ID!) {
              docker {
                mutations {
                  stopContainer(id: $containerId) {
                    id
                    names
                    image
                    state
                    status
                  }
                }
              }
            }
          ''';

  static const String startDocker = r'''
            query StartContainer($containerId: ID!) {
              docker {
                mutations {
                  startContainer(id: $containerId) {
                    id
                    names
                    image
                    state
                    status
                  }
                }
              }
            }
          ''';
}
