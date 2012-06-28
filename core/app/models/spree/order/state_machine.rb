Spree::Order.class_eval do
  # order state machine (see http://github.com/pluginaweek/state_machine/tree/master for details)
  state_machine :initial => 'cart', :use_transactions => false do

    event :next do
      transition :from => 'cart',     :to => 'address'
      transition :from => 'address',  :to => 'delivery'
      transition :from => 'delivery', :to => 'payment', :if => :payment_required?
      transition :from => 'delivery', :to => 'complete'
      transition :from => 'confirm',  :to => 'complete'

      # note: some payment methods will not support a confirm step
      transition :from => 'payment',  :to => 'confirm',
        :if => Proc.new { |order| order.payment_method && order.payment_method.payment_profiles_supported? }

      transition :from => 'payment', :to => 'complete'
    end

    event :cancel do
      transition :to => 'canceled', :if => :allow_cancel?
    end
    event :return do
      transition :to => 'returned', :from => 'awaiting_return'
    end
    event :resume do
      transition :to => 'resumed', :from => 'canceled', :if => :allow_resume?
    end
    event :authorize_return do
      transition :to => 'awaiting_return'
    end

    before_transition :to => 'complete' do |order|
      order.process_payments!
    end

    before_transition :to => 'delivery', :do => :remove_invalid_shipments!

    after_transition :to => 'complete', :do => :finalize!
    after_transition :to => 'delivery', :do => :create_tax_charge!
    after_transition :to => 'payment',  :do => :create_shipment!
    after_transition :to => 'resumed',  :do => :after_resume
    after_transition :to => 'canceled', :do => :after_cancel

  end

  # This method should be overriden to be false if some of your orders have items
  # that are all "undeliverable", i.e. there is no need for a shipping address
  # This is for things such as online-only goods, and the like.
  def needs_delivery?
    true
  end
end
