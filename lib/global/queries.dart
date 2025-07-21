class Queries {
  static const String getDockers = r'''
    query {
      docker { 
        containers { 
          id, names, image, imageId, command, created, sizeRootFs, labels, state, status, networkSettings, mounts, autoStart 
        } 
      } 
    }
  ''';

  static const String getVms = r'''
    query Query {
      vms { id, domain { id, uuid, name, state } }
    }
  ''';

  static const String getArray = r'''
    query { 
      array {
        state
        boot {
          id, name, status, size, device
        }
        disks {
          id, name, status, size, device
        }
        parities {
          id, name, status, size, device
        }
        caches {
          id, name, status, size, device
        }
      } 
    }
  ''';

  static const String getShares = r'''
    query {
      shares {
        name, free, used, size, include, exclude, cache, nameOrig, comment, allocator, splitLevel, floor, cow, color, luksStatus
      }
    }
  ''';

  static const String getServices = r'''
    query {
      services {
        id, name, version
      }
    }
  ''';

  static const String getInfo = r'''
      query {
        info {
          cpu {
            manufacturer
            brand
            vendor
            family
            model
            stepping
            revision
            voltage
            speed
            speedmin
            speedmax
            threads
            cores
            processors
            socket
            cache
          }
          baseboard {
            manufacturer
            model
            version
            serial
            assetTag
          }
          os {
            platform
            distro
            release
            codename
            kernel
            arch
            hostname
            codepage
            logofile
            serial
            build
            uptime
          }
          memory {
          }
        }
      }
  ''';

  static const getPlugins = r'''
    query {
      plugins {
        name
        version
        hasApiModule
        hasCliModule
      }
    }
  ''';

}
