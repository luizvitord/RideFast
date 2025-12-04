defmodule RideFast.GlobalTest do
  use RideFast.DataCase

  alias RideFast.Global

  describe "languages" do
    alias RideFast.Global.Language

    import RideFast.GlobalFixtures

    @invalid_attrs %{code: nil, name: nil}

    test "list_languages/0 returns all languages" do
      language = language_fixture()
      assert Global.list_languages() == [language]
    end

    test "get_language!/1 returns the language with given id" do
      language = language_fixture()
      assert Global.get_language!(language.id) == language
    end

    test "create_language/1 with valid data creates a language" do
      valid_attrs = %{code: "some code", name: "some name"}

      assert {:ok, %Language{} = language} = Global.create_language(valid_attrs)
      assert language.code == "some code"
      assert language.name == "some name"
    end

    test "create_language/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Global.create_language(@invalid_attrs)
    end

    test "update_language/2 with valid data updates the language" do
      language = language_fixture()
      update_attrs = %{code: "some updated code", name: "some updated name"}

      assert {:ok, %Language{} = language} = Global.update_language(language, update_attrs)
      assert language.code == "some updated code"
      assert language.name == "some updated name"
    end

    test "update_language/2 with invalid data returns error changeset" do
      language = language_fixture()
      assert {:error, %Ecto.Changeset{}} = Global.update_language(language, @invalid_attrs)
      assert language == Global.get_language!(language.id)
    end

    test "delete_language/1 deletes the language" do
      language = language_fixture()
      assert {:ok, %Language{}} = Global.delete_language(language)
      assert_raise Ecto.NoResultsError, fn -> Global.get_language!(language.id) end
    end

    test "change_language/1 returns a language changeset" do
      language = language_fixture()
      assert %Ecto.Changeset{} = Global.change_language(language)
    end
  end
end
