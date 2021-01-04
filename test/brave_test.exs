defmodule BraveTest do
  use Brave.DataCase

  describe "find missing params" do
    test "returns desired error map", _ do
      assert %{errors: %{"field1" => ["required field"], "field3" => ["required field"]}} = Brave.find_missing_params(%{"field2" => "val"}, ["field1","field2","field3"])
    end
  end
end
