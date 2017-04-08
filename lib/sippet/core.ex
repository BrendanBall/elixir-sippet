defmodule Sippet.Core do
  alias Sippet.Message, as: Message
  alias Sippet.Message.RequestLine, as: RequestLine
  alias Sippet.Message.StatusLine, as: StatusLine

  @type ignore :: term

  @type reason :: atom

  @type incoming_request ::
    %Message{start_line: %RequestLine{}}

  @type incoming_response ::
    %Message{start_line: %StatusLine{}}

  @type client_transaction ::
    {module, binary, atom | binary} |
    nil

  @type server_transaction ::
    {module, binary, {binary, integer}, atom | binary} |
    nil

  @type client_or_server_transaction ::
    client_transaction |
    server_transaction

  @doc """
  Receives a new incoming request from a remote host, or ACK.
  """
  @callback receive_request(incoming_request, server_transaction) :: ignore

  @doc """
  Receives a response for a sent request.
  """
  @callback receive_response(incoming_response, client_transaction) :: ignore

  @doc """
  Sends receives an error from the transaction.
  """
  @callback receive_error(reason, client_or_server_transaction) :: ignore

  @spec receive_request(incoming_request, server_transaction) :: ignore
  def receive_request(incoming_request, server_transaction) do
    args = [incoming_request, server_transaction]
    apply(get_module!(), :receive_request, args)
  end

  defp get_module!() do
    module = Application.get_env(:sippet, __MODULE__)
    if module == nil do
      raise RuntimeError, message: "Sippet.Core is not registered"
    else
      module
    end
  end

  @spec receive_response(incoming_response, client_transaction) :: ignore
  def receive_response(incoming_response, client_transaction) do
    args = [incoming_response, client_transaction]
    apply(get_module!(), :receive_response, args)
  end

  @spec receive_error(reason, client_or_server_transaction) :: ignore
  def receive_error(reason, client_or_server_transaction) do
    args = [reason, client_or_server_transaction]
    apply(get_module!(), :receive_error, args)
  end
end