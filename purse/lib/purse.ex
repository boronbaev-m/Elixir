defmodule Purse do
  def create(values) when is_map(values) do
    if check_map(values) do
      spawn(Purse, :loop, [values])
    else
      {:error, "Invalid argument"}
    end
  end

  def create(_values) do
    {:error, "Invalid argument"}
  end

  def create() do
    spawn(Purse, :loop, [%{}])
  end

  def check_map(map) do
    map
    |> Map.keys()
    |> Enum.all?(fn key -> is_atom(key) end) and
      map
      |> Map.values()
      |> Enum.all?(fn value -> is_number(value) and value >= 0 end)
  end

  # Does not work if loop is private for some reason
  def loop(state) do
    new_state =
      receive do
        {:peek, sender_pid, ref} ->
          send(sender_pid, {state, ref})
          state

        {:peek, currency, sender_pid, ref} ->
          res = Map.get(state, currency)
          send(sender_pid, {res, ref})
          state

        {:deposit, currency, amount, sender_pid, ref} ->
          res = change_state(state, currency, amount)
          send(sender_pid, ref)
          res

        {:withdraw, currency, amount, sender_pid, ref} ->
          temp = -amount

          res =
            cond do
              state[currency] == nil ->
                send(sender_pid, {:error_currency, ref})
                state

              state[currency] >= amount ->
                temp = change_state(state, currency, temp)
                send(sender_pid, ref)
                temp

              true ->
                send(sender_pid, {:error_amount, ref})
                state
            end

          res
      end

    loop(new_state)
  end

  def change_state(map, currency, amount) do
    new_map =
      case map[currency] do
        nil ->
          Map.put(map, currency, amount)

        value ->
          res = amount + value
          %{map | currency => res}
      end

    new_map
  end

  def peek(pid) when is_pid(pid) do
    if Process.alive?(pid) do
      ref = make_ref()
      send(pid, {:peek, self(), ref})

      receive do
        {state, ^ref} -> {:ok, state}
        _ -> {:error, "Returned reference in not equal to the initial one"}
      end
    else
      {:error, "Purse is dead"}
    end
  end

  def peek(_pid) do
    {:error, "Invalid argument"}
  end

  def peek(pid, currency) when is_pid(pid) and is_atom(currency) do
    if Process.alive?(pid) do
      ref = make_ref()
      send(pid, {:peek, currency, self(), ref})

      receive do
        {nil, ^ref} -> {:error, "No such currency in the purse"}
        {value, ^ref} -> {:ok, value}
        _ -> {:error, "Returned reference in not equal to the initial one"}
      end
    else
      {:error, "Purse is dead"}
    end
  end

  def peek(_pid, _currency) do
    {:error, "Invalid arguments"}
  end

  def deposit(pid, currency, amount)
      when is_pid(pid) and is_atom(currency) and is_number(amount) and amount >= 0 do
    if Process.alive?(pid) do
      ref = make_ref()
      send(pid, {:deposit, currency, amount, self(), ref})

      receive do
        ^ref -> {:ok, "Success"}
        _ -> {:error, "Returned reference in not equal to the initial one"}
      end
    else
      {:error, "Purse is dead"}
    end
  end

  def deposit(_pid, _currency, _amount) do
    {:error, "Invalid arguments"}
  end

  def withdraw(pid, currency, amount)
      when is_pid(pid) and is_atom(currency) and is_number(amount) and amount >= 0 do
    if Process.alive?(pid) do
      ref = make_ref()
      send(pid, {:withdraw, currency, amount, self(), ref})

      receive do
        ^ref -> {:ok, "Success"}
        {:error_currency, ^ref} -> {:error, "No such currency"}
        {:error_amount, ^ref} -> {:error, "Not enough money"}
        _ -> {:error, "Returned reference in not equal to the initial one"}
      end
    else
      {:error, "Purse is dead"}
    end
  end

  def withdraw(_pid, _currency, _amount) do
    {:error, "Invalid arguments"}
  end
end
