defmodule ChatProgramming.ModelHandler do
  def all() do
    {:ok, %{data: models}} = OpenAI.models()
    ExStructTranslator.to_atom_struct(models)
  end

  @doc """
     (model must be one of ada, babbage, curie, davinci) or a fine-tuned model created by your organization.
  """
  def models(:trainable) do
    all()
    |> Enum.filter(fn %{permission: permission} ->
      permission|> Enum.fetch!(0) |> Map.fetch!(:allow_fine_tuning)
    end)
  end

  # def models_created() do
  #   all_ol = all()
  #   all_local = OpenAIModel.all()
  #   Enum.map(all_local, fn model_local ->
  #     Enum.find(all_ol, fn model_ol -> )
  #   end)
  # end

  def delete(model_id) do
    OpenAI.finetunes_delete_model(model_id)
  end

  def get_finetune(nil), do: nil
  def get_finetune(finetune_id) do
    {:ok, %{data: finetune_history}} = OpenAI.finetunes_list_events(finetune_id)
    finetune_history
  end

  def check_finetuen_state(history) do
    history
    |> Enum.fetch!(-1)
    |> Map.fetch!("message")
    |> Kernel.==("Fine-tune succeeded")
  end

  def get_model_name(history) do
    event =
      history
      |> Enum.find(fn %{"message" => msg} ->
        {prefix, _model_name} = msg |> String.split_at(16)
        prefix == "Uploaded model: "
      end)
    case event do
      nil ->
        nil
      %{"message" => msg} ->
        {_prefix, model_name} = msg |> String.split_at(16)
        model_name
    end
  end

end
