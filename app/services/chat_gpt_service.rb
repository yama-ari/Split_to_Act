# app/services/chat_gpt_service.rb
require 'openai'

OpenAI.configure do |config|
  config.access_token = ENV['OPENAI_API_KEY']
end

class ChatGptService
  def self.generate_reply(prompt)
    client = OpenAI::Client.new

    response = client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [
          {
            role: "system",
            content: <<~PROMPT
              あなたの役割は、ユーザーが入力した曖昧なタスクを具体的な行動ステップに分解することです。
              出力は：
              - 日本語
              - 箇条書きで最低3項目
              - 各項目は10〜30分で終わる行動にする
              - 感情表現や挨拶は含めない
            PROMPT
          },
          { role: "user", content: prompt }
        ],
        max_tokens: 300,
        temperature: 0.7
      }
    )

    response.dig("choices", 0, "message", "content")
  end

  # 🔽 ここから追記
  def self.generate_reply_raw(prompt)
    client = OpenAI::Client.new

    client.chat(
      parameters: {
        model: "gpt-4o",
        messages: [
          {
            role: "system",
            content: <<~PROMPT
              ユーザーが入力した曖昧なタスクを、具体的な行動ステップに分解してください。
              出力形式：
              - 日本語
              - 箇条書き
              - 各ステップは10〜30分で終わるようにする
              - 装飾や感情表現は使わない
            PROMPT
          },
          { role: "user", content: prompt }
        ],
        max_tokens: 500,
        temperature: 0.7
      }
    )
  end
end
