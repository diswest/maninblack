module ManHelper
  def suggest_domain(domain)
    render(partial: 'suggest_button', locals: {domain: domain})
  end
end
