defmodule GoCardlessClient.ConfigTest do
  use ExUnit.Case, async: true

  alias GoCardlessClient.Config

  describe "new/1" do
    test "returns {:ok, config} with valid options" do
      assert {:ok, config} = Config.new(access_token: "tok")
      assert config.access_token == "tok"
      assert config.environment == :sandbox
      assert config.timeout == 30_000
      assert config.max_retries == 3
    end

    test "accepts :live environment" do
      assert {:ok, config} = Config.new(access_token: "tok", environment: :live)
      assert config.environment == :live
    end

    test "applies custom timeout and retries" do
      assert {:ok, config} = Config.new(access_token: "tok", timeout: 10_000, max_retries: 5)
      assert config.timeout == 10_000
      assert config.max_retries == 5
    end

    test "returns error when access_token is missing" do
      assert {:error, %NimbleOptions.ValidationError{}} = Config.new([])
    end

    test "returns error for invalid environment" do
      assert {:error, %NimbleOptions.ValidationError{}} =
               Config.new(access_token: "tok", environment: :invalid)
    end
  end

  describe "new!/1" do
    test "returns config map on success" do
      config = Config.new!(access_token: "tok")
      assert is_map(config)
      assert config.access_token == "tok"
    end

    test "raises ArgumentError on invalid config" do
      assert_raise ArgumentError, fn -> Config.new!([]) end
    end
  end

  describe "base_url/1" do
    test "returns sandbox URL for :sandbox environment" do
      config = Config.new!(access_token: "tok", environment: :sandbox)
      assert Config.base_url(config) == "https://api-sandbox.gocardless.com"
    end

    test "returns live URL for :live environment" do
      config = Config.new!(access_token: "tok", environment: :live)
      assert Config.base_url(config) == "https://api.gocardless.com"
    end
  end

  describe "schema/0" do
    test "returns a NimbleOptions schema" do
      schema = Config.schema()
      assert %NimbleOptions{} = schema
    end
  end
end
