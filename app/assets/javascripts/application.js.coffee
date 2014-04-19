#= require jquery
#= require jquery_ujs
#= require underscore/underscore-min
#= require bootstrap.min
#= require jquery.carouFredSel-6.2.1-packed
#= require jquery-ui-1.10.3/js/jquery-ui-1.10.3.custom.min
#= require jquery-ui-1.10.3/touch-fix.min
#= require isotope/jquery.isotope.min
#= require bootstrap-tour/build/js/bootstrap-tour.min
#= require prettyphoto/js/jquery.prettyPhoto
#= require goMap/js/jquery.gomap-1.3.2.min
#= require custom
#= require modernizr.custom.56918
#= require spin
#= require jquery.spin
#= require typeahead_2
#= require hogan-2.0.0

# Attach a function or variable to the global namespace
root = exports ? this

#####################################
#    Check if console exists (IE)   #
#####################################
log = (message) ->
  if typeof console is 'object' then console.log(message) else return null

$(document).ready ->
    update_sku()
    select_shipping()
    loading_animation_settings()
    modal('.notify_me', '#notifyMeModal')
    typeahead_engine()
    update_accessory()
    use_billing_address()

    $('.update_shipping #address_country').change ->
        unless @value is ""
        	$.ajax '/order/shippings/update',
        		type: 'GET'
        		data: {'country_id' : @value, 'tier_id' : $('.shipping-methods').attr 'data-tier' }
        		dataType: 'html'
        		success: (data) ->
        			$('.shipping-methods .control-group .controls').html data
        else 
            $('.shipping-methods .control-group .controls').html '<p class="shipping_notice">Select a shipping country to view the available shipping options.</p>'

    $('#update_quantity').click ->
        $('.edit_cart_item').each ->
            $(@).submit()

    loading_modal('.paypal_checkout', '#paypalModal')
    loading_modal('.confirm_order', '#confirmOrderModal')

$(document).ajaxComplete ->
    update_sku()
    select_shipping()
    modal('.notify_me', '#notifyMeModal')
    form_JSON_errors()

form_JSON_errors = ->
    $(document).on "ajax:error", "form", (evt, xhr, status, error) ->
        errors = $.parseJSON(xhr.responseJSON.errors)
        $.each errors, (key, value) ->
            $element = $("input[name*='" + key + "']")
            $error_target = '.error_explanation'
            if $element.parent().next().is $error_target
                $($error_target).html '<span>' + key + '</span> ' + value
            else 
                $element.wrap '<div class="field_with_errors"></div>'
                $element.parent().after '<span class="' + $error_target.split('.').join('') + '"><span>' + key + '</span> ' + value + '</span>'

modal = (trigger, target) ->
    $(trigger).click ->
        $(target).modal 'show'
        return false

loading_modal = (trigger, target) ->
    $(trigger).click ->
        $(target).modal 'show'
        $(target + ' .modal-body .loading_block').spin 'standard'

select_shipping = ->
    $('.shipping-methods .option').click ->
        $(@).find('input:radio').prop 'checked', true
        $('.option').removeClass 'active'
        $(@).addClass 'active'
    $('.shipping-methods .option input:radio').each ->
        $(@).parent().addClass 'active' if $(@).is ':checked'

update_sku = ->
    $('#cart_item_sku_id').change ->
        sku_id = $(@).val()
        accessory_id = $('#cart_item_cart_item_accessory_accessory_id').val()
        $.get '/product/skus/update?sku_id=' + sku_id + '&accessory_id=' + accessory_id

update_accessory = ->
    $('#cart_item_cart_item_accessory_accessory_id').change ->
        accessory_id = $(@).val()
        sku_id = $('#cart_item_sku_id').val()
        $.get '/product/accessories/update?accessory_id=' + accessory_id + '&sku_id=' + sku_id

use_billing_address = ->
    $('.use_billing_address').change ->
        if @checked
            $('.use_billing').each ->
                $(@).val $(@).next('div').text()
            $('.field_with_errors').each ->
                $(@).children('input').val $(@).next('div').text()
        else
            $('.use_billing').val ''

loading_animation_settings = ->
    $.fn.spin.presets.standard =
        lines: 9 # The number of lines to draw
        length: 0 # The length of each line
        width: 10 # The line thickness
        radius: 18 # The radius of the inner circle
        corners: 1 # Corner roundness (0..1)
        rotate: 0 # The rotation offset
        direction: 1 # 1: clockwise, -1: counterclockwise
        color: "#e54b5d" # #rgb or #rrggbb
        speed: 0.8 # Rounds per second
        trail: 42 # Afterglow percentage
        shadow: false # Whether to render a shadow
        hwaccel: false # Whether to use hardware acceleration
        className: "spinner" # The CSS class to assign to the spinner
        zIndex: 2e9 # The z-index (defaults to 2000000000)
        top: "auto" # Top position relative to parent in px
        left: "auto" # Left position relative to parent in px

typeahead_engine = ->
    $("#navSearchInput").typeahead(
        remote: "/search/autocomplete?utf8=✓&query=%QUERY"
        # prefetch: "/search.json"
        template: " <div class='inner-suggest'>
                        <img src='{{image.file.url}}' height='45' width='45'/>
                        <span>
                            <div>{{value}}</div>
                            <div>{{category_name}}{{}}</div>
                        </span>
                    </div>"
        engine: Hogan
        limit: 4
    ).on "typeahead:selected", ($e, data) ->
        window.location = "/categories/" + data.category_slug + "/products/" + data.product_slug



