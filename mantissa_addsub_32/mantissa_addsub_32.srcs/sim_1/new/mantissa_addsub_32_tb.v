`timescale 1ns / 1ps

module tb_mantissa_addsub_32();

    // Testbench signals
    reg A_sign;
    reg B_sign;
    reg [22:0] A;
    reg [22:0] B;
    wire [22:0] Sum;
    wire Sign;
    wire Overflow;
    
    // Test counter
    integer test_num;
    integer pass_count;
    integer fail_count;
    
    // Instantiate the DUT (Device Under Test)
    mantissa_addsub_32 dut (
        .A_sign(A_sign),
        .B_sign(B_sign),
        .A(A),
        .B(B),
        .Sum(Sum),
        .Sign(Sign),
        .Overflow(Overflow)
    );
    
    // Task for displaying test results
    task display_test;
        input [7:0] test_number;
        input [255:0] test_description;
        begin
            $display("Test %0d: %s", test_number, test_description);
            $display("  Inputs:  A_sign=%b, B_sign=%b, A=%h, B=%h", A_sign, B_sign, A, B);
            $display("  Outputs: Sum=%h, Sign=%b, Overflow=%b", Sum, Sign, Overflow);
            $display("");
        end
    endtask
    
    // Task for checking expected results
    task check_result;
        input [22:0] expected_sum;
        input expected_sign;
        input expected_overflow;
        input [255:0] test_desc;
        begin
            if (Sum === expected_sum && Sign === expected_sign && Overflow === expected_overflow) begin
                $display("✓ PASS: %s", test_desc);
                pass_count = pass_count + 1;
            end else begin
                $display("✗ FAIL: %s", test_desc);
                $display("  Expected: Sum=%h, Sign=%b, Overflow=%b", expected_sum, expected_sign, expected_overflow);
                $display("  Got:      Sum=%h, Sign=%b, Overflow=%b", Sum, Sign, Overflow);
                fail_count = fail_count + 1;
            end
            $display("");
        end
    endtask
    
    initial begin
        $display("========================================");
        $display("Mantissa Addition/Subtraction Testbench");
        $display("========================================");
        $display("");
        
        // Initialize counters
        test_num = 0;
        pass_count = 0;
        fail_count = 0;
        
        // Initialize inputs
        A_sign = 0;
        B_sign = 0;
        A = 23'b0;
        B = 23'b0;
        
        #10; // Wait for initial settling
        
        // Test 1: Basic addition with same positive signs
        test_num = test_num + 1;
        A_sign = 0; B_sign = 0;
        A = 23'h100000; // 1.0 in mantissa
        B = 23'h080000; // 0.5 in mantissa
        #10;
        display_test(test_num, "Same sign addition (positive)");
        check_result(23'h180000, 0, 0, "1.0 + 0.5 = 1.5");
        
        // Test 2: Basic addition with same negative signs
        test_num = test_num + 1;
        A_sign = 1; B_sign = 1;
        A = 23'h200000;
        B = 23'h100000;
        #10;
        display_test(test_num, "Same sign addition (negative)");
        check_result(23'h300000, 1, 0, "(-2.0) + (-1.0) = -3.0");
        
        // Test 3: Subtraction - A > B (different signs, effectively A + |B|)
        test_num = test_num + 1;
        A_sign = 0; B_sign = 1;
        A = 23'h300000;
        B = 23'h100000;
        #10;
        display_test(test_num, "Different signs, A > B");
        check_result(23'h200000, 0, 0, "3.0 - 1.0 = 2.0");
        
        // Test 4: Subtraction - A < B (different signs)
        test_num = test_num + 1;
        A_sign = 0; B_sign = 1;
        A = 23'h100000;
        B = 23'h300000;
        #10;
        display_test(test_num, "Different signs, A < B");
        check_result(23'h200000, 1, 0, "1.0 - 3.0 = -2.0");
        
        // Test 5: Subtraction - A = B (result should be zero)
        test_num = test_num + 1;
        A_sign = 0; B_sign = 1;
        A = 23'h200000;
        B = 23'h200000;
        #10;
        display_test(test_num, "Different signs, A = B");
        check_result(23'h000000, 0, 0, "2.0 - 2.0 = 0.0");
        
        // Test 6: Overflow test (same signs)
        test_num = test_num + 1;
        A_sign = 0; B_sign = 0;
        A = 23'h7FFFFF; // Maximum mantissa
        B = 23'h000001; // Minimum non-zero
        #10;
        display_test(test_num, "Overflow test");
        check_result(23'h000000, 0, 1, "Max + 1 causes overflow");
        
        // Test 7: Large numbers same sign
        test_num = test_num + 1;
        A_sign = 1; B_sign = 1;
        A = 23'h400000;
        B = 23'h200000;
        #10;
        display_test(test_num, "Large numbers, same sign");
        check_result(23'h600000, 1, 0, "Large negative addition");
        
        // Test 8: Small numbers different signs
        test_num = test_num + 1;
        A_sign = 0; B_sign = 1;
        A = 23'h000010;
        B = 23'h000008;
        #10;
        display_test(test_num, "Small numbers, different signs");
        check_result(23'h000008, 0, 0, "Small subtraction");
        
        // Test 9: Zero handling
        test_num = test_num + 1;
        A_sign = 0; B_sign = 0;
        A = 23'h000000;
        B = 23'h100000;
        #10;
        display_test(test_num, "Zero + non-zero");
        check_result(23'h100000, 0, 0, "0 + 1.0 = 1.0");
        
        // Test 10: Both zeros
        test_num = test_num + 1;
        A_sign = 0; B_sign = 1;
        A = 23'h000000;
        B = 23'h000000;
        #10;
        display_test(test_num, "Zero handling");
        check_result(23'h000000, 0, 0, "0 - 0 = 0");
        
        // Test 11: Maximum values same sign (should overflow)
        test_num = test_num + 1;
        A_sign = 0; B_sign = 0;
        A = 23'h7FFFFF;
        B = 23'h7FFFFF;
        #10;
        display_test(test_num, "Maximum values addition");
        check_result(23'h7FFFFE, 0, 1, "Max + Max = Overflow");
        
        // Test 12: Edge case - alternating bits
        test_num = test_num + 1;
        A_sign = 1; B_sign = 0;
        A = 23'h555555;
        B = 23'h2AAAAA;
        #10;
        display_test(test_num, "Alternating bit patterns");
        check_result(23'h2AAAAB, 1, 0, "Alternating bits test");
        
        // Summary
        $display("========================================");
        $display("Test Summary:");
        $display("Total Tests: %0d", test_num);
        $display("Passed:      %0d", pass_count);
        $display("Failed:      %0d", fail_count);
        
        if (fail_count == 0) begin
            $display("🎉 ALL TESTS PASSED!");
        end else begin
            $display("❌ Some tests failed. Please review.");
        end
        
        $display("========================================");
        $finish;
    end
    
    // Monitor for debugging (optional - uncomment if needed)
    /*
    initial begin
        $monitor("Time=%0t: A_sign=%b B_sign=%b A=%h B=%h => Sum=%h Sign=%b Overflow=%b", 
                 $time, A_sign, B_sign, A, B, Sum, Sign, Overflow);
    end
    */
    
endmodule