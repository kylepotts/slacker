defmodule Slacker.Users do
  def grab_users(api_token) do
    grab_users_api_call(api_token)
  end

  defp grab_users_api_call(api_token) do
    {:ok,resp} = Slacker.Web.users_list(api_token)
    resp[:members] |> filter_users
  end

  defp filter_users(users) do
    map = Enum.reduce(users,%{}, fn(user,acc) ->
      id = user["id"]
      name = user["profile"]["real_name"]
      Map.put(acc,id,name)
    end)
  end

end
