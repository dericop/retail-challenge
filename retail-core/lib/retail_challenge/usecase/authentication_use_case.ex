defmodule RetailChallenge.UseCase.AuthenticationUseCase do
  alias RetailChallenge.Adapters.Repositories.UserDGateway
  def validate_session(token) do
    case UserDGateway.get_by_token(token) do
      {:ok, user} -> {:ok, user}
      {:error, :not_found} -> {:error, :invalid_credentials}
      error -> error
    end
  end
end
