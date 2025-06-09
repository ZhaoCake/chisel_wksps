package your_package_name

import chisel3._

class YourMain extends Module {
  val io = IO(new Bundle {
    // Define your module's I/O here
    // For example:
    val in = Input(UInt(32.W))
    val out = Output(UInt(32.W))
  })

  // Your module logic goes here
  // For example:
  io.out := io.in + 1.U
}