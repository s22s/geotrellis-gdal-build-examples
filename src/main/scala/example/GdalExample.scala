package example

import geotrellis.gdal._

object GdalExample extends App {
  for {
    path <- Seq(
      "/data/B03.jp2",
      "/data/MCD43A4.A2017006.h21v11.006.2017018074804_B01.TIF",
      "/data/LC08_L1GT_200110_20170907_20170907_01_RT_B3.TIF"
    )
  } GDALInfo.main(Array(path))
}

