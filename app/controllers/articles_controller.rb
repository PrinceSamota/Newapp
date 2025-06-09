class ArticlesController < ApplicationController
  def manual_decode
    article_number = params[:article_number] || params[:article_no]
    decoder = ArticleDecoder.new(article_number)
    decoded = decoder.decode
  
    respond_to do |format|
      format.html { render :manual_decode }
      format.json { render json: decoded }
    end
  end

  def manual_decode_post
    article_number = params[:article_number]
    decoded = ArticleDecoder.new(article_number).decode

    session[:decoded_data] = decoded
    session[:article_number] = article_number
    redirect_to manual_decode_result_path
  end

  def manual_decode_result
    decoded = session[:decoded_data]
    article_number = session[:article_number]

    if decoded.nil?
      redirect_to manual_decode_path, alert: "No article decoded. Please try again."
    else
      render :manual_decode_result, locals: { article_number: article_number, decoded: decoded }
    end
  end
end
