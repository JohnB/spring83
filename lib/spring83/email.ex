defmodule Spring83.Email do
  use Bamboo.Phoenix, view: Spring83.SharedView

  def welcome_text_email(email_address, body \\ "Test from Spring83") do
    new_email()
    |> to(email_address)
    |> from("john.baylor@gmail.com")
    |> subject("Welcome!")
    |> text_body(body)
  end
end
