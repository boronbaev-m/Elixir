defmodule PurseTest do
  use ExUnit.Case
  doctest Purse

  test "Purse.create() creates a purse" do
    assert is_pid(Purse.create())
  end

  test "Purse.create(%{currency: amount}) creates a purse with appropriate values" do
    pid = Purse.create(%{usd: 1})
    assert is_pid(pid)
    assert Purse.peek(pid) == {:ok, %{usd: 1}}
  end

  test "Purse.create(%{currency: amount}) checks if values provided are correct" do
    err = Purse.create(%{"usd" => 1})
    err1 = Purse.create([1, 2])
    err2 = Purse.create(%{usd: -1})
    err3 = Purse.create(%{usd: 1, eur: -2})

    assert !is_pid(err)
    assert err == {:error, "Invalid argument"}

    assert !is_pid(err1)
    assert err1 == {:error, "Invalid argument"}

    assert !is_pid(err2)
    assert err2 == {:error, "Invalid argument"}

    assert !is_pid(err3)
    assert err3 == {:error, "Invalid argument"}
  end

  test "Purse.peek(pid) checks if process is alive" do
    pid = Purse.create()
    assert Purse.peek(pid) == {:ok, %{}}
    Process.exit(pid, "kill")
    assert Purse.peek(pid) == {:error, "Purse is dead"}
  end

  test "Purse.peek(pid) checks if argument is correct" do
    pid = Purse.create()
    assert Purse.peek(:pid) == {:error, "Invalid argument"}
  end

  test "Purse.peek(pid, currency) of a new purse returns an error" do
    pid = Purse.create()
    assert Purse.peek(pid, :usd) == {:error, "No such currency in the purse"}
  end

  test "Purse.peek(pid, currency) returns an error if the purse does not contain such currency" do
    pid = Purse.create(%{eur: 1})
    assert Purse.peek(pid, :usd) == {:error, "No such currency in the purse"}
  end

  test "Purse.peek(pid, currency) of a purse that contain that value returns the value" do
    pid = Purse.create(%{usd: 1})
    assert Purse.peek(pid, :usd) == {:ok, 1}

    pid1 = Purse.create(%{usd: 1, eur: 2})
    assert Purse.peek(pid1, :eur) == {:ok, 2}
  end

  test "Purse.peek(pid, currency) checks if process is alive" do
    pid = Purse.create(%{usd: 1})
    Process.exit(pid, "kill")
    assert Purse.peek(pid, :usd) == {:error, "Purse is dead"}
  end

  test "Purse.peek(pid, currency) checks if arguments are correct" do
    pid = Purse.create(%{usd: 1})
    assert Purse.peek(:pid, :usd) == {:error, "Invalid arguments"}
    assert Purse.peek(pid, "usd") == {:error, "Invalid arguments"}
  end

  test "Purse.deposit(pid, currency, amount1) checks if the purse is alive" do
    pid = Purse.create()
    assert Purse.peek(pid) == {:ok, %{}}

    Process.exit(pid, "kill")
    Purse.deposit(pid, :usd, 1)
    assert Purse.peek(pid) == {:error, "Purse is dead"}
  end

  test "Purse.deposit(pid, currency, amount) checks if arguments are correct" do
    pid = Purse.create(%{eur: 2})
    assert Purse.peek(pid) == {:ok, %{eur: 2}}

    assert Purse.deposit(:pid, :eur, 1) == {:error, "Invalid arguments"}
    assert Purse.peek(pid) == {:ok, %{eur: 2}}

    assert Purse.deposit(pid, "eur", 1) == {:error, "Invalid arguments"}
    assert Purse.peek(pid) == {:ok, %{eur: 2}}

    assert Purse.deposit(pid, :eur, "1") == {:error, "Invalid arguments"}
    assert Purse.peek(pid) == {:ok, %{eur: 2}}

    assert Purse.deposit(pid, :eur, -1) == {:error, "Invalid arguments"}
    assert Purse.peek(pid) == {:ok, %{eur: 2}}
  end

  test "Purse.deposit(pid, currency, amount) creates a new value in an empty purse" do
    pid = Purse.create()
    assert Purse.peek(pid) == {:ok, %{}}

    Purse.deposit(pid, :usd, 1)
    assert Purse.peek(pid) == {:ok, %{usd: 1}}
  end

  test "Purse.deposit(pid, currency, amount) creates a new value in a non empty purse" do
    pid = Purse.create(%{eur: 2})
    assert Purse.peek(pid) == {:ok, %{eur: 2}}

    Purse.deposit(pid, :usd, 1)
    assert Purse.peek(pid) == {:ok, %{eur: 2, usd: 1}}
  end

  test "Purse.deposit(pid, currency, amount) changes the value of the currency if it is present in purse" do
    pid = Purse.create(%{eur: 2})
    assert Purse.peek(pid) == {:ok, %{eur: 2}}

    Purse.deposit(pid, :eur, 1)
    assert Purse.peek(pid) == {:ok, %{eur: 3}}
  end

  test "Purse.withdraw(pid, currency, amount) checks if the purse is alive" do
    pid = Purse.create()
    assert Purse.peek(pid) == {:ok, %{}}

    Process.exit(pid, "kill")
    Purse.withdraw(pid, :usd, 1)
    assert Purse.peek(pid) == {:error, "Purse is dead"}
  end

  test "Purse.withdraw(pid, currency, amount) checks if arguments are correct" do
    pid = Purse.create(%{eur: 2})
    assert Purse.peek(pid) == {:ok, %{eur: 2}}

    assert Purse.withdraw(:pid, :eur, 1) == {:error, "Invalid arguments"}
    assert Purse.peek(pid) == {:ok, %{eur: 2}}

    assert Purse.withdraw(pid, "eur", 1) == {:error, "Invalid arguments"}
    assert Purse.peek(pid) == {:ok, %{eur: 2}}

    assert Purse.withdraw(pid, :eur, "1") == {:error, "Invalid arguments"}
    assert Purse.peek(pid) == {:ok, %{eur: 2}}

    assert Purse.withdraw(pid, :eur, -1) == {:error, "Invalid arguments"}
    assert Purse.peek(pid) == {:ok, %{eur: 2}}
  end

  test "Purse.withdraw(pid, currency, amount) does not create a new value in an empty purse" do
    pid = Purse.create()
    assert Purse.peek(pid) == {:ok, %{}}

    assert Purse.withdraw(pid, :usd, 1) == {:error, "No such currency"}
    assert Purse.peek(pid) == {:ok, %{}}
  end

  test "Purse.withdraw(pid, currency, amount) does not create a new value in a non empty purse" do
    pid = Purse.create(%{eur: 2})
    assert Purse.peek(pid) == {:ok, %{eur: 2}}

    assert Purse.withdraw(pid, :usd, 1) == {:error, "No such currency"}
    assert Purse.peek(pid) == {:ok, %{eur: 2}}
  end

  test "Purse.withdraw(pid, currency, amount) does not change the value if there in not enough money in the purse" do
    pid = Purse.create(%{eur: 2})
    assert Purse.peek(pid) == {:ok, %{eur: 2}}

    assert Purse.withdraw(pid, :eur, 3) == {:error, "Not enough money"}
    assert Purse.peek(pid) == {:ok, %{eur: 2}}
  end

  test "Purse.withdraw(pid, currency, amount) changes the value of the currency if it is present in purse" do
    pid = Purse.create(%{eur: 5})
    assert Purse.peek(pid) == {:ok, %{eur: 5}}

    Purse.withdraw(pid, :eur, 3)
    assert Purse.peek(pid) == {:ok, %{eur: 2}}
  end
end
