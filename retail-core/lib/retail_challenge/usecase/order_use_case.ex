defmodule RetailChallenge.UseCase.OrderUseCase do
  alias RetailChallenge.Adapters.Repositories.{ProductGateway, SaleGateway, Sale}
  alias RetailChallenge.UseCase.ErrorsHandler
  alias RetailChallenge.Model.SuccessModel

  def handle_order_request(%{sku: sku, units: units}, user) when is_binary(sku) and units > 0 do

    with {:ok, product} <- ProductGateway.get_by_sku(sku),
         {:ok, _} <- ProductGateway.update_stock(product, units),
         sale <- Sale.new(units, product, user),
         {:ok, %{id: id}} <- SaleGateway.save(sale)
      do
      SuccessModel.new("#{id}")
    else
      error -> ErrorsHandler.handle_error(error)
    end
  end

  def handle_order_request(_body, _units) do
    ErrorsHandler.handle_error({:error, :invalid_request})
  end

end
