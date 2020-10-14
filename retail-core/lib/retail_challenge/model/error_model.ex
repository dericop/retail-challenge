defmodule RetailChallenge.Model.ErrorModel do
  @moduledoc false

  defstruct [
    orderstatus: "Rejected",
    Reason: ""
  ]

  def new(reason) do
    %__MODULE__{
      Reason: reason
    }
  end

end
