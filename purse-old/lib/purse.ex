defmodule Purse do
  @moduledoc """
  Documentation for `Purse`.

  """

  @doc """

  ## Examples

      iex> Purse.create()

  """

  def create do
    spawn_link(Purse, :run, [%{}, self()])
  end

  def run(purse, main_pid) do
    new_purse = receive do
      {:deposit, currency, amount, ref} ->
        IO.inspect(ref, label: "Recieved deposit request from")
        cond do
          !is_atom(currency) ->
            send(main_pid, {:bad_currency, ref})
            purse
          !is_number(amount) ->
            send(main_pid, {:bad_amount, ref})
            purse
          purse[currency] == nil ->
            purse = Map.put(purse, currency, amount)
            send(main_pid, {:ok, ref})
          true ->
            temp = purse[currency] + amount
            purse = %{purse | currency => temp}
            send(main_pid, {:ok, ref})
        end

      {:withdraw, currency, amount, ref} ->
        IO.inspect(ref, label: "Recieved withdraw request from")
        cond do
          !is_atom(currency) ->
            send(main_pid, {:bad_currency, ref})
          !is_number(amount) ->
            send(main_pid, {:bad_amount, ref})
          purse[currency] == nil ->
            amount = -amount
            purse = Map.put(purse, currency, amount)
            send(main_pid, {:ok, ref})
          true ->
            temp = purse[currency] - amount
            purse = %{purse | currency => temp}
            send(main_pid, {:ok, ref})
        end

      {:all_currenices, ref} ->
        cond do
          purse == %{} ->
            send(main_pid, {:empty, ref})
          true ->
            IO.puts("Your balance:")
            for curr <- purse, do: IO.puts("#{to_string(curr)}: #{purse[curr]}")
            send(main_pid, {:ok, ref})
        end

      {currency, ref} ->
        cond do
          purse == %{} ->
            send(main_pid, {:empty, ref})
          !is_atom(currency) ->
            send(main_pid, {:bad_currency, ref})
          purse[currency] == nil ->
            send(main_pid, {:no_currency, ref})
          true->
            IO.puts("Your balance in #{to_string(currency)}: #{purse[currency]}")
            send(main_pid, {:ok, ref})
        end
    end

    run(new_purse, main_pid)
  end

  def deposit(purse, currency, amount) do
    unless Process.alive?(purse) do
      Process.exit(purse, :no_purse)
    end

    send(purse, {:deposit, currency, amount, make_ref()})

    receive do
      {:ok, ref} -> IO.inspect(ref, label: "Deposit was successful")
      {:bad_currency, ref} -> IO.inspect(ref, label: "Deposit failed, currency is not an atom")
      {:bad_amount, ref} -> IO.inspect(ref, label: "Deposit failed, incorrect amount")
    end
  end

  def withdraw(purse, currency, amount) do
    unless Process.alive?(purse) do
      Process.exit(purse, :no_purse)
    end

    send(purse, {:deposit, currency, amount, make_ref()})

    receive do
      {:ok, ref} -> IO.inspect(ref, label: "Withdrawal was successful")
      {:bad_currency, ref} -> IO.inspect(ref, label: "Withdrawal failed, currency is not an atom")
      {:bad_amount, ref} -> IO.inspect(ref, label: "Withdrawal failed, incorrect amount")
    end
  end

  def peek(purse) do
    unless Process.alive?(purse) do
      Process.exit(purse, :no_purse)
    end

    send(purse, {:all_currencies, make_ref()})

    receive do
      {:ok, ref} -> IO.inspect(ref, label: "Account information was recieved successfully")
      {:empty, ref} -> IO.inspect(ref, label: "Your account is empty")
    end
  end

  def peek(purse, currency) do
    unless Process.alive?(purse) do
      Process.exit(purse, :no_purse)
    end

    send(purse, {currency, make_ref()})

    receive do
      {:ok, ref} -> IO.inspect(ref, label: "Account information was recieved successfully")
      {:empty, ref} -> IO.inspect(ref, label: "Your account is empty")
      {:bad_currency, ref} -> IO.inspect(ref, label: "Could not get an account information, currency is not an atom")
      {:no_currency, ref} -> IO.inspect(ref, label: "Could not get an account information, no such currency")
    end
  end
end
