function expand_hello_world(inline)
  if inline.c == '{{mundo}}' then
    return pandoc.Emph{ pandoc.Str "Olá mundo!" }
  else
    return inline
  end
end

return {{Str = expand_hello_world}}
