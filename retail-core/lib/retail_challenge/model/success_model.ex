defmodule RetailChallenge.Model.SuccessModel do
  @moduledoc false

  defstruct [
    orderstatus: "Successful",
    orderid: ""
  ]

  def new(order_id) do
    %__MODULE__{
      orderid: order_id
    }
  end

end
