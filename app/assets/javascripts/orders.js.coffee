# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'))
  payment.setupForm()

  $('#pay_using_cc').click ->
    showAppropriateDiv()

  $('#pay_using_pp').click ->
    showAppropriateDiv()




payment =
  setupForm: ->
    $('#new_order').submit ->
      $('input[type=submit]').attr('disabled', true)
      if $('#card_number:visible').length
        payment.processStripe()
        false
      else
        true

  processStripe: ->
    card =
      number: $('#card_number').val()
      cvc: $('#card_code').val()
      expMonth: $('#card_month').val()
      expYear: $('#card_year').val()
    Stripe.createToken(card, payment.handleStripeResponse)

  handleStripeResponse: (status, response) ->
    if status == 200
      $('#new_order').append($('<input type="hidden" name="stripeToken" />').val(response.id))
      $('#new_order')[0].submit()
    else
      $('#stripe_error').text(response.error.message).show()
      $('input[type=submit]').attr('disabled', false)



showAppropriateDiv = ->
  if $('#pay_using_cc').is(':checked')
    $('.credit-card-fields').slideDown()
    populatePaymentInfo()
  else
    $('.credit-card-fields').slideUp()
    emptyPaymentInfo()


populatePaymentInfo = ->
  $('#card_number').val('4242424242424242')
  $('#card_code').val('111')
  $('#card_month').val('5')
  $('#card_year').val('2016')

emptyPaymentInfo = ->
  $('#card_number').val()
  $('#card_code').val()
  $('#card_month').val()
  $('#card_year').val()
