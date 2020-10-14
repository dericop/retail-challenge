defmodule RetailChallenge.UseCase.OrderUseCase do
    alias RetailChallenge.Adapters.Repositories.{ProductGateway, SaleGateway, Sale }
    alias RetailChallenge.UseCase.ErrorsHandler

    def handle_order_request(user, %{sku: sku, units: units}) do
        
        with {:ok, product} <- ProductGateway.get_by_sku(sku),
        {:ok, _} <- ProductGateway.update_stock(product, units) 
        {:ok, %{id: id}} <- SaleGateway.save(Sale.new(units, product, user))

        do
          %{orderstatus: "Successfull", orderid: "#{id}"}
          else
            error -> ErrorsHandler.handle_error(error)
        end
    
    end

end