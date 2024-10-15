// Based on: https://www.edaplayground.com/x/Yk4N
class scoreboard;

  int number_of_scoreboards = 0;

  string sb_name [$];

  mailbox #(logic [31:0]) expected_mb [$];
  mailbox #(logic [31:0]) actual_mb [$];

  int unsigned match_count [$];
  int unsigned mismatch_count [$];

  function new(string names[$]);
    mailbox #(logic [31:0]) my_mb;

    number_of_scoreboards = names.size();

    for (int i = 0; i < number_of_scoreboards; i++) begin
      my_mb = new();
      expected_mb.push_back(my_mb);

      my_mb = new();
      actual_mb.push_back(my_mb);

      match_count.push_back(0);
      mismatch_count.push_back(0);

      sb_name.push_back(names[i]);
    end
  endfunction : new

  task check();
    for (int i = 0; i < number_of_scoreboards; i++) begin
      fork
        automatic int inst_id = i;
        begin
          wait_for_data(inst_id);
        end
      join_none
    end
  endtask : check

  task wait_for_data(int inst_id);
    logic [31:0] expected_data;
    logic [31:0] actual_data;

    $display("Time: %0t, start with task wait_for_data on instance %0d!", $time, inst_id);

    forever begin
      expected_mb[inst_id].peek(expected_data);
      actual_mb[inst_id].peek(actual_data);

      if (expected_data == actual_data) begin
        $display("Time: %0t, data matched in scoreboard %s with expected = 0x%0h and actual = 0x%0h!", $time, sb_name[inst_id], expected_data, actual_data);
        match_count[inst_id]++;
      end
      else begin
        $display("Time: %0t, data mismatched in scoreboard %s with expected = 0x%0h and actual = 0x%0h!", $time, sb_name[inst_id], expected_data, actual_data);
        mismatch_count[inst_id]++;
      end

      expected_mb[inst_id].get(expected_data);
      actual_mb[inst_id].get(actual_data);
    end
  endtask : wait_for_data

  function final_checker();
    for (int inst_id = 0; inst_id < number_of_scoreboards; inst_id++) begin
      $display("Time: %0t, scoreboard %s finished with %0d matches and %0d mismatches!", $time, sb_name[inst_id], match_count[inst_id], mismatch_count[inst_id]);
      $display("Time: %0t, scoreboard %s finished with %0d expected items waiting to be processed!", $time, sb_name[inst_id], expected_mb[inst_id].num());
      $display("Time: %0t, scoreboard %s finished with %0d actual items waiting to be processed!", $time, sb_name[inst_id], actual_mb[inst_id].num());

      if (mismatch_count[inst_id] > 0) begin
        $display("Time: %0t, scoreboard %s finished with some mismatches, TEST FAILED!", $time, sb_name[inst_id]);
      end
    end
  endfunction : final_checker

endclass : scoreboard
