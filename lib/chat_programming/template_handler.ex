defmodule ChatProgramming.TemplateHandler do
    def gen_prompt(template_content, the_map) do
        Enum.reduce(the_map, template_content, fn {key, value}, acc ->
            key_str = Atom.to_string(key)
            IO.puts "{#{key_str}}"
            String.replace(acc, "{#{key_str}}", value)
        end)
    end
end