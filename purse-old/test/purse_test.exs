defmodule PurseTest do
  use ExUnit.Case
  doctest Purse

  test "Create a walet" do
    assert is_pid Purse.create()
  end

  # Increase/Decrease the amount of money in a particular currency in the wallet deposit(purse, currency, amount)
  test "deposit/3 checks if a purse is alive" do
    purse = Purse.create()
    Purse.deposit(purse, :usd, 10)    
  end

  test "deposit/3 sends a message to a purse " do

  end

  test "deposit/3 waits for a response from a purse " do

  end

  test "deposit/3 detects if the purse dies during execution and return the appropriate error" do

  end

  test "withdraw/3 checks if a purse is alive" do

  end

  test "withdraw/3 sends a message to a purse " do

  end

  test "withdraw/3 waits for a response from a purse " do

  end

  test "withdraw/3 detects if the purse dies during execution and return the appropriate error" do

  end

  test "recieve message" do

  end

  test "purse extracts sender from the message" do

  end

  test "Extract ref from the message" do

  end

  test "Extract currency from the message" do

  end

  test "Extract amount from the message" do

  end

  test "Change the value in the wallet depending on the currency and amount" do

  end

  test "Return the result" do

  end
end
