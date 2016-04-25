defmodule Slacker.Users do
  def grab_users(api_token) do
    grab_users_api_call(api_token)
  end

  defp grab_users_api_call(api_token) do
    {:ok,resp} = Slacker.Web.users_list(api_token)
    IO.inspect(resp)
  end
end
