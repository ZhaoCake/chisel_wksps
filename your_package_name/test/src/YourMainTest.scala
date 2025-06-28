package your_package_name

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec

class YourMainTest extends AnyFlatSpec with ChiselScalatestTester {
  "YourMain" should "add 1 to input" in {
    test(new YourMain) { dut =>
      // Test case 1
      dut.io.in.poke(0.U)
      dut.clock.step(1)
      dut.io.out.expect(1.U)
      
      // Test case 2
      dut.io.in.poke(42.U)
      dut.clock.step(1)
      dut.io.out.expect(43.U)
      
      // Test case 3
      dut.io.in.poke(0xFFFFFFFF.U)
      dut.clock.step(1)
      dut.io.out.expect(0.U) // Overflow case
    }
  }
}
