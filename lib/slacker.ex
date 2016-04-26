defmodule Slacker do

  defmodule State do
    defstruct api_token: nil, rtm: nil, state: nil, users: nil
  end

  defmacro __using__(_opts) do
    quote do
      use GenServer
      require Logger
      alias Slacker.Web

      @before_compile unquote(__MODULE__)

      def start_link(api_token, options \\ []) do
        GenServer.start_link(__MODULE__, api_token, options)
      end

      def init(api_token) do
        GenServer.cast(self, :connect)
        users = Slacker.Users.grab_users(api_token)
        {:ok, %State{api_token: api_token, users: users}}
      end

      def say(slacker, channel, message) do
        GenServer.cast(slacker, {:send_message, channel, message})
      end

      def lookup_user(slacker, user_id) do
        GenServer.call(slacker,{:lookup_user, user_id})
      end

      def handle_cast(:connect, state) do
        {:ok, auth} = Web.auth_test(state.api_token)
        Logger.info(~s/Successfully authenticated as user "#{auth.user}" on team "#{auth.team}"/)


        {:ok, rtm_response} = Web.rtm_start(state.api_token)
        {:ok, rtm} = Slacker.RTM.start_link(rtm_response.url, self)

        {:noreply, %{state | rtm: rtm}}
      end

      def handle_cast({:send_message, channel, msg}, state) do
        GenServer.cast(state.rtm, {:send_message, channel, msg})
        {:noreply, state}
      end

      def handle_call({:lookup_user, user_id}, _from, state) do
        {:reply,"Test",state}
      end
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def handle_cast({:handle_incoming, type, msg}, state) do
        Logger.debug "#{type} -> #{inspect msg}"
        {:noreply, state}
      end
    end
  end
end
