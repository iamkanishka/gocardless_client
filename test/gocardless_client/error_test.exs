defmodule GoCardlessClient.ErrorTest do
  use ExUnit.Case, async: true

  alias GoCardlessClient.{APIError, Error, FieldError}

  describe "APIError.from_response/2" do
    test "builds from a well-formed GoCardlessClient error body" do
      body = %{
        "error" => %{
          "type" => "validation_failed",
          "message" => "Validation failed",
          "request_id" => "reqxyz",
          "documentation_url" => "https://developer.gocardless.com/api-reference/#errors",
          "errors" => [
            %{
              "field" => "amount",
              "message" => "is not a number",
              "request_pointer" => "/payments/amount"
            }
          ]
        }
      }

      err = APIError.from_response(422, body)

      assert %APIError{} = err
      assert err.status == 422
      assert err.type == "validation_failed"
      assert err.message == "Validation failed"
      assert err.request_id == "reqxyz"
      assert length(err.errors) == 1
      assert [%FieldError{field: "amount"}] = err.errors
    end

    test "handles missing errors array" do
      body = %{
        "error" => %{
          "type" => "gocardless_error",
          "message" => "Internal error",
          "request_id" => "req_500",
          "errors" => []
        }
      }

      err = APIError.from_response(500, body)
      assert err.errors == []
    end

    test "handles non-map body gracefully" do
      err = APIError.from_response(503, "Service Unavailable")
      assert err.status == 503
      assert err.message == "Unexpected response body"
    end
  end

  describe "APIError predicates" do
    test "not_found?/1" do
      assert APIError.not_found?(%APIError{status: 404})
      refute APIError.not_found?(%APIError{status: 422})
    end

    test "conflict?/1" do
      assert APIError.conflict?(%APIError{status: 409})
      refute APIError.conflict?(%APIError{status: 404})
    end

    test "validation_failed?/1" do
      assert APIError.validation_failed?(%APIError{type: "validation_failed"})
      refute APIError.validation_failed?(%APIError{type: "gocardless_error"})
    end

    test "rate_limited?/1" do
      assert APIError.rate_limited?(%APIError{status: 429})
    end

    test "invalid_state?/1" do
      assert APIError.invalid_state?(%APIError{type: "invalid_state"})
    end

    test "server_error?/1" do
      assert APIError.server_error?(%APIError{type: "gocardless_error"})
    end
  end

  describe "APIError is an Exception" do
    test "Exception.message/1 returns a readable string" do
      err = %APIError{status: 422, message: "Validation failed", request_id: "req_abc"}
      msg = Exception.message(err)
      assert msg =~ "422"
      assert msg =~ "Validation failed"
      assert msg =~ "req_abc"
    end
  end

  describe "Error constructors" do
    test "timeout/0" do
      err = Error.timeout()
      assert %Error{reason: :timeout} = err
      assert err.message =~ "timed out"
    end

    test "circuit_open/0" do
      err = Error.circuit_open()
      assert err.reason == :circuit_open
    end

    test "budget_exhausted/0" do
      err = Error.budget_exhausted()
      assert err.reason == :rate_limit_budget_exhausted
    end

    test "network/1" do
      exc = %RuntimeError{message: "connection refused"}
      err = Error.network(exc)
      assert match?({:network, _}, err.reason)
      assert err.message =~ "connection refused"
    end
  end

  describe "FieldError.from_map/1" do
    test "maps raw API error fields" do
      raw = %{
        "field" => "email",
        "message" => "is invalid",
        "request_pointer" => "/customers/email"
      }

      fe = FieldError.from_map(raw)

      assert %FieldError{
               field: "email",
               message: "is invalid",
               request_pointer: "/customers/email"
             } =
               fe
    end

    test "handles missing keys gracefully" do
      fe = FieldError.from_map(%{})
      assert fe.field == nil
      assert fe.message == nil
    end
  end
end
