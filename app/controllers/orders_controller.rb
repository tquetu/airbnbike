class OrdersController < ApplicationController
  def create
    booking = Booking.find(params[:booking_id])
    @order = Order.create!(booking: booking, amount: booking.compute_price, state: 'pending', user: current_user)
  
    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        name: booking.id,
        amount: booking.compute_price,
        currency: 'eur',
        quantity: 1
      }],
      success_url: order_url(@order),
      cancel_url: order_url(@order)
    )
  
    @order.update(checkout_session_id: session.id)
    redirect_to new_order_payment_path(@order)
    authorize @order
  end

  def show
    @order = current_user.orders.find(params[:id])
    authorize @order
  end

end
