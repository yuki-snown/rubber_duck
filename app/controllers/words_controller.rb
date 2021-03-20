
require 'natto'
require 'securerandom'

# debugger => binding.pry

class WordsController < ApplicationController
    def health
        render json: {'msg': "OK"}, :status => 200  
    end

    def search
        surface = []
        feature = []
        natto = Natto::MeCab.new
        key = ''
        pattern = ''
        flag = false

        # 言語処理系 一致するkey, patternを抽出 or resp文章を作成
        natto.parse(params[:text]) do |n|
            if n.surface.include?("ひより") then
                flag = true
                surface.push("はーい！！")
                break
            elsif n.surface.include?("すごい") then
                flag = true
                surface.push("でしょ！")
                break
            elsif n.feature.include?("感動詞") then
                flag = true
                surface.push("#{n.surface}！！")
                break
            elsif n.surface.include?("ない") && surface[-1].include?("でき") then
                flag = true
                surface.push("どうして，#{surface[-2]}ができないの？")
                break
            elsif n.feature.include?("形容詞") || n.feature.include?("動詞") 
                key = "#{n.surface}"
                pattern = "#{surface[-1]}#{n.surface}"
            end
            surface.push(n.surface)
            feature.push(n.feature.split(',')[0])
        end

        # 検索とrespの処理系
        if flag then
            render json: {'msg': "#{surface[-1]}"}, :status => 200
        else
            msg =  Word.order(rank: :desc).find_by(key: [key, '*'], pattern: [pattern, '*'])
            if msg.present? then
                render json: {'msg': "#{msg.message}"}, :status => 200                
            else
                rnd = SecureRandom.random_number(2)
                if rnd == 1 then
                    render json: {'msg': "ごめんよ！分かんないや"}, :status => 200
                elsif
                    render json: {'msg': "だよね！"}, :status => 200
                end
            end    
        end
    end
end