class MessagesController < ApplicationController
  before_action :authenticate_user!

  def index
    @message = Message.new
    @messages = Message.order(created_at: :asc)
  end

  def create
    @message = Message.new(content: params[:message][:content])
  
    if @message.save
      reply = ChatGptService.generate_reply(@message.content)
      Message.create(content: reply) if reply.present?
      redirect_to messages_path
    else
      @messages = Message.order(created_at: :asc)
      render :index
    end
  end  

  def ask
    # ユーザーがタスクを入力するページを表示
  end

  def answer
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

    prompt = params[:question]

    response = client.chat(
      parameters: {
        model: "gpt-4o",
        messages: [
          {
            role: "system",
            content: <<~PROMPT
              あなたは、ユーザーが入力した曖昧なタスクや目標を、具体的な行動に落とし込む専門アシスタントです。
              出力ルールは以下のとおり：
              - 日本語で出力
              - 箇条書きで最低3個以上
              - 各ステップは10〜30分で実行可能な粒度にする
              - 記号やマークダウン（例: *, **）は使わない
              - 無駄なあいさつ・感情表現を含めない（例：こんにちは、頑張ってね、など）
              - ユーザー入力を繰り返さない
            PROMPT
          },
          { role: "user", content: prompt }
        ],
        max_tokens: 400,
        temperature: 0.7
      }
    )

    if response["choices"]&.first&.dig("message", "content").present?
      @answer = response["choices"][0]["message"]["content"]
    else
      @answer = "行動ステップを生成できませんでした"
    end

    respond_to do |format|
      format.turbo_stream
    end
  end
end
