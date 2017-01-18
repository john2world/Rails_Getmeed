module PromotionsManager

  def enter_promotion(user_handle, referrer, campaign_type)
    if campaign_type.blank?
      campaign_type = 'spotify'
    end
    promotion_id = "#{user_handle}_#{campaign_type}"
    promotion = UserPromotion.find(promotion_id)
    if promotion.blank?
      promotion = UserPromotion.new
      promotion.id = promotion_id
      promotion.type = campaign_type
      promotion.handle = user_handle
      promotion.referrer = referrer
      promotion.save
    end
  end
end