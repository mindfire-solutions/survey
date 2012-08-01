$(document).ready(function(){

/*Initialise loading image path*/
  var loader = '<div class="loader_container"><img src="/assets/survey/loading.gif" class="loading" /></div>'

/* Initialise the datatables for question, question sets and evaluations */

  $('#questions_list').dataTable({
    "aoColumns": [
                    null,
                    null,
                    null,
                    { "bSortable": false }
                 ]
  });

  $('#evaluation_list').dataTable({
    "aoColumns": [
                    null,
                    null,
                    { "bSortable": false }
                 ]
  });

/* show/hide the validations/selections based on question type */

  $('#survey_question_question_type').live('change', function(){

    if ($(this).val() == "Text Box")
    {
      $('#validations').css('display', 'block');
      $('#validations .fields input[type=checkbox]').removeAttr('disabled');
      $('#selections').css('display', 'none');
      $('#selections .fields input[type="text"]').each(function(){
        if($(this).parent().find('.destroy_field').length == 0)
          $(this).parent().find('input').attr('disabled', 'disabled');
        else
          $(this).parent().find('.destroy_field').val(1)
      });
    }
    else if($(this).val() == "Text Box(Date)")
    {
      $('#validations').css('display', 'none');
      $('#selections').css('display', 'none');
      $('#validation_list .validation_params input').attr('disabled', 'disabled');
      $('#selections .fields input[type="text"]').each(function(){
        if($(this).parent().find('.destroy_field').length == 0)
          $(this).parent().find('input').attr('disabled', 'disabled');
        else
          $(this).parent().find('.destroy_field').val(1)
      });
    }
    else
    {
      $('#validations').css('display', 'none');
      $('#validations .fields input[type="checkbox"]').removeAttr('checked');
      $('#selections').css('display', 'block');
      $('#selections .fields input').removeAttr('disabled');
      $('#validation_list .validation_params input').attr('disabled', 'disabled');
      $('#validation_list .validation_params').hide();
    }

  });

/* remove the content if remove link is clicked */

  $('.remove_link').live('click', function(){
    removable = $(this).parent('.fields').parent('.fields');
    //alert($(this).parent().find('.destroy_field').length);
    if($(this).parent().find('.destroy_field').length > 0)
    {
      $(this).parent().find('.destroy_field').val(1);
      removable.hide();
    }
    else
      $(this).parent('.fields').parent('.fields').remove();
    return false;
  });

/* perform collapse and expand on category links */

  $('span.collapse').live('click', function(){
    $(this).parent().parent().children('ul').css('display', 'none');
    $(this).css('display', 'none');
    $(this).prev('span.expand').css('display', 'inline-block');
  });

  $('span.expand').live('click', function(){
    $(this).parent().parent().children('ul').css('display', 'block');
    $(this).css('display', 'none');
    $(this).next('span.collapse').css('display', 'inline-block');
  });

  $('li.question input[type="checkbox"], li.question_set input[type="checkbox"]').live("click", function(){
    var item = $(this).parent();
    item_content = '<li><span class="title" >'+$(item).html()+'</span> ';
    item_content += '<span class="item_type"> '+$(item).attr('class')+' </span> ';
    item_content += '<span class="actions"><a href="#" class="remove_item"> remove </a></span></li>';
    ele = $("#show_selected_items ul").find("#"+$(this).attr('id'));

    if($(this).is(':checked'))
    {
      $(this).parent().find('.destroy_field').val(0);
      if(ele.length <= 0)
      {
        $("#show_selected_items ul").append(item_content);
        $('#show_selected_items li:last span.title').children('input[type="checkbox"]').attr('checked', 'checked');
      }
    }
    else
    {
      $(this).parent().find('.destroy_field').val(1);
      if(ele.length > 0 )
        ele.parent().parent().remove();
    }

  });

  $('#show_selected_items ul.items li span.title').live("focus", function(){
    var reference_type = $(this).find('input[type="hidden"].item_type').val();
    if(reference_type == "Survey::SurveyQuestion")
    {
      var checkbox = $(this).find('input[type="checkbox"]');
      var object = checkbox.attr('name');
      var question = checkbox.val();
      var index = object.lastIndexOf('[');
      object = object.substring(0, index);
      $('#show_selected_items .item_conditions span a.add_condition').attr('value', object);
      $('#show_selected_items .item_conditions span a.add_condition').attr('question', question);
      $('#show_selected_items .item_conditions').css('display', 'block');
      $('#show_selected_items .item_conditions .conditions_container').css('display', 'none');
      $('#show_selected_items .item_conditions div#item_'+question).css('display', 'block');
    }
    else
      $('#show_selected_items .item_conditions').css('display', 'none');

    $('#show_selected_items ul.items li.selected').removeClass('selected');
    $(this).parent().addClass('selected');
  });

  $('#show_selected_items ul.items li span.title').live("click", function(){
    $(this).trigger("focus")
  });

  $('.choose_from input[type="radio"]').live('change', function(){
    var choose_from = $(this).val();
    var set_id = 0
    if($('form').hasClass('edit_survey_question_set'))
    {
            form_id = $('form').attr('id');
            set_id = form_id.substring(form_id.lastIndexOf('_')+1);
            //alert(set_id);
    }
    if(choose_from == "all")
    {
      $('#list_question_categories').html('');
      $('#show_questions, #show_question_sets').html(loader);
      $.get( "/survey/survey_questions/get_questions",
             { category: choose_from, id: set_id }
           );
    }
    else
    {
      $('#list_question_categories').html(loader);
      $.get( "/survey/survey_question_categories", { id: set_id} );
    }

  });

  /*Add loading image to show_questions and sets div*/
  $('#list_question_categories a').live('ajax:beforeSend', function(){
    $('#show_questions, #show_question_sets').html(loader);
  });

  $('div.categories ul a, #cat-all').live('ajax:beforeSend', function(){
    $('.list_content .dataTable tbody').html('<tr><td colspan="4" class="loading_cell">'+loader+'</td></tr>');
  });

  $('.tabs .tab').live('click', function(){

    if($(this).next().hasClass('selected'))
      active_tab = $(this).next();
    else
      active_tab = $(this).prev();

    current_tab_id = $(this).attr('id');
    $(this).addClass('selected');
    active_tab.removeClass('selected');
    $("#show_" + active_tab.attr('id')).addClass('hidden');
    $("#show_" + current_tab_id).removeClass('hidden');
    if( current_tab_id == "selected_items")
    {
      $("#show_" + current_tab_id + " ul.items li:nth-child(2) span.title").trigger("focus");
    }
  });

  $('#show_selected_items .item_conditions span a.add_condition').live('click', function(){
    $('body').append('<div id="edit_overlay" class="facebox_overlay">'+loader+'</div>');
    $.get( "/survey/survey_question_sets/add_condition",
      { object: $(this).val(), question: $(this).attr('question') }
    );
    return false;
  });

  $('.facebox button[name="action"]').live("click", function(){
    var button_val = $(this).val();
    var facebox_id = $(this).parent().parent().parent('.content').parent('.popup').parent('.facebox').attr('id');

    if( button_val == 'cancel')
      $('#' + facebox_id + ' .popup a.close').trigger('click');
    else
    {
      var content = $(this).parent().parent();
      var condition = content.attr('id').substring(10);
      var title = $('#' + facebox_id + ' .popup .content').find('input.condition_title').val();
      title = $.trim(title);
      var html_class = title.replace(' ', '-');

      $('#' + facebox_id + ' .popup .content').find('input.condition_title').val(title);

      if(title == ''){
        alert('Please enter the condition title');
      }
      else if($('.'+html_class).length > 0 && !$('.'+html_class).hasClass(condition)){
        alert('Please specify a different title.');
      }
      else
      {
        var question_id = $(this).attr('question');
        var condition_html = '<div class="conditions '+condition+' '+html_class+'">';
        condition_html += '<span class="title"> '+title+' </span> ';
        condition_html += '<span class="actions"> <a condition="'+condition+'" class="edit_condition" href="#">edit</a> </span> ';
        condition_html += '<span class="actions"> <a condition="'+condition+'" class="remove_condition" href="#">remove</a> </span> <div>';

        if( $('#show_selected_items div.item_conditions .' + condition).length == 0 )
        {
          if( $('#show_selected_items div.item_conditions div#item_'+question_id).length == 0 )
          {
            $('#show_selected_items div.item_conditions').append('<div id="item_'+question_id+'" class="conditions_container"></div>');
          }

          $('#show_selected_items div.item_conditions div#item_'+question_id).append(condition_html);
        }
        else
        {
          $('#show_selected_items div.item_conditions .' + condition + ' .title').html(title);
          $('#hidden_conditions #'+content.attr('id')).remove();
        }

        $('#hidden_conditions').append(content);

        $('#' + facebox_id + ' .popup a.close').trigger('click');
        return false;
      }
    }
  });

  $('#show_selected_items .item_conditions span a.edit_condition').live('click', function(){
    ts = new Date();
    ts = ts.getTime();
    condition = '#condition_' + $(this).attr('condition');
    $.facebox({div: condition}, false, 'facebox' + ts);
    $('#facebox' + ts + ' .content').css('width', '400px');
    left = parseFloat($('#facebox' + ts).css('left').substring(-2)) + 150;
    $('#facebox' + ts).css('left', left + 'px');
    //$.facebox.settings.callback = '';
    //$('#hidden_conditions').append($('#facebox' + ts + ' .content').html());
    sel_val = $('#hidden_conditions '+condition+' .condition_reference').val();
    $('.facebox '+condition+' .condition_reference').val(sel_val);

    $('#hidden_conditions '+condition+' input[type=checkbox]').each(function(){
      if($(this).is(':checked'))
        $('.facebox #'+$(this).attr('id')).attr('checked', 'checked');
      else
        $('.facebox #'+$(this).attr('id')).removeAttr('checked');
    });

    return false;
  });

  $('#show_selected_items .item_conditions span a.remove_condition').live('click', function(){
    if(confirm('Are you sure?'))
    {
      hidden_condition = $('#hidden_conditions #condition_' + $(this).attr('condition'));

      if(hidden_condition.find('.destroy_field').length > 0)
        hidden_condition.find('.destroy_field').val(1);
      else
        hidden_condition.remove();

      $(this).parent().parent().remove();
    }
    return false;
  });

  $('#show_selected_items .remove_item').live('click', function(){
    if(confirm('Are you sure?'))
    {
      checkbox = $(this).parent().parent().find('input[type=checkbox]');
      associated_ele = $('.show_category_items #'+checkbox.attr('id'));
      $('#hidden_conditions .condition_for_'+checkbox.val()).remove();
      $('#show_selected_items .item_conditions #item_'+checkbox.val()).remove();
      associated_ele.removeAttr('checked');
      associated_ele.parent().find('.destroy_field').val(1);
      $(this).parent().parent('li').remove();
      $('#show_selected_items .item_conditions').css('display', 'none');
      $("#show_selected_items ul.items li:nth-child(2) span.title").trigger("focus");
    }
    return false;
  });

  /*$('.edit_published_set').click(function(){
          return ( confirm("The Question set is published! Do you want to create a new version?") )
  });

  $('.edit_published_question').click(function(){
          return ( confirm("The Question is published! Do you want to create a new version?") )
  });
  */

  $('.edit, .add_question a, .add_category a, .add_question_set a, #evaluation_list form input[type=submit]').live('click', function(){
    $('body').append('<div id="edit_overlay" class="facebox_overlay">'+loader+'</div>');
  });

  $('.condition_reference_type').live('change', function(){
    select = $(this).parent().next().children('select.condition_reference');
    select.html('<option>Loading...</option>');

    if($(this).val() == 2)
    {
      $.getJSON('/survey/survey_question_sets', function(result){
        select.html('');   // clear the existing options
        $.each(result,function(i, o){
          $('<option value="' + o.id + '">' + o.title + ' (' + o.version + ')' + '</option>').appendTo(select);
        });
      });
    }
    else
    {
      $.getJSON('/survey/survey_questions', function(result){
        select.html('');   // clear the existing options
        $.each(result,function(i, o){
          $('<option value="' + o.id + '">' + o.text + ' (' + o.version + ')' + '</option>').appendTo(select);
        });
      });
    }
  });

  $('.condition_fields input[type="checkbox"]').live('click', function(){
    if($(this).is(':checked'))
      $(this).prev('.destroy_field').val(0);
    else
      $(this).prev('.destroy_field').val(1);
  });


  $('#validations input[type="checkbox"]').live('focus', function(){
    $(this).parent().trigger('click');
  });

  $('#validations .fields span.validation_title').live('click', function(){
    prev_validation = $('#validations .fields span.selected');
    valid = true;

    if(!$(this).is(prev_validation) && prev_validation.children('input[type="checkbox"]').is(':checked')) {
      prev_validation.next('span.validation_params').find('input').each(function(){
        if($(this).val() == "") {
          valid = false;
          $(this).css('border', '1px solid red');
        }
      });
    }

    if(valid)
    {
      if(!$(this).is(prev_validation)) {
        prev_validation.removeClass('selected');
        $(this).addClass('selected');
        $('#validations .fields span.validation_params').fadeOut(1000);
      }
      else {
        if($(this).hasClass('checked'))
          valid = false;
      }

      if($(this).children('input[type="checkbox"]').is(':checked'))
      {
        if(valid) {
          $(this).next('span.validation_params').find('input').removeAttr('disabled');
          $(this).next('span.validation_params').animate({
                                                                                                                                                                                                                        width: ['toggle', 'swing'],
                                                                                                                                                                                                                        opacity: 'toggle'
                                                                                                                                                                                                                }, 1000, 'linear');
        }
        $(this).addClass('checked');
      }
      else
      {
        $(this).removeClass('checked');
        $(this).next('span.validation_params').find('input').attr('disabled', 'disabled');
        $(this).next('span.validation_params').fadeOut(1000);
      }
    }
    else {
      $.facebox('Please fill up the validation parameters first!');
    }
  });

  $('.question_tree span.title').live('click', function(){
    params = {};
    $('span.title.selected').removeClass('selected');
    $(this).addClass('selected');

    $('#selected_question .evaluation').hide();

    if($(this).children('input[name=item_id]').length > 0)
    {
      params['eval_id'] = $('#eval_id').val();
      evaluation_item = $(this).children('input[name=item_id]').val();

      if($('#evaluate_item_'+evaluation_item).length == 0)
      {
        $('body').append('<div id="edit_overlay" class="facebox_overlay"></div>');
        $('#selected_question').append('<div id="evaluation_overlay" class="facebox_overlay">'+loader+'</div>');
        params['item_id'] = evaluation_item;

        if($(this).children('input[name=question_id]').length > 0)
                params['question_id'] = $(this).children('input[name=question_id]').val();

        if($(this).children('input[name=level]').length > 0)
                params['level'] = $(this).children('input[name=level]').val();

        if($(this).children('input[name=object]').length > 0)
                params['object'] = $(this).children('input[name=object]').val();

        $.get( "/survey/survey_evaluations/evaluate_question", params );
      }
      else
      {
        $('#evaluate_item_'+evaluation_item).show();
      }
    }
  });

  $('input.answer_text').live('focus', function(){
    $(this).css('border', '');
    $(this).parent().next().find('button.evaluate_question').removeAttr('disabled');
  });

  $('.evaluate_question').live('click', function(){
    prev_div = $(this).parent().prev();
    valid = true;

    if(prev_div.children('select').length > 0)
      selected_val = prev_div.children('select').val();
    else if(prev_div.children('input[type=radio]').length > 0)
      selected_val = prev_div.children('input[type=radio]:checked').val();
    else if(prev_div.children('input[type=checkbox]').length > 0)
    {
      selected_val = new Array();
      index = 0;
      prev_div.children('input[type=checkbox]:checked').each(function(){
        selected_val[index] = $(this).val();
        index++;
      });

      prev_div.find('.selections').val(selected_val);
    }
    else if(prev_div.children('input[type=text]').length > 0)
    {
      selected_val = prev_div.children('input[type=text]').val();
      valid = prev_div.children('input[type=text]').trigger('blur');
    }
    else{}

    item_level	= prev_div.children('.level').val();
    item_object = prev_div.children('input:first').attr('name');
    index = item_object.lastIndexOf('[');
    item_object = item_object.substring(0, index);

    if(valid && prev_div.children('input[name=condition]').val() == 1)
    {
      evalution_item = $(this).parent().parent('.evaluation').attr('id').substring(-1);
      $.get( "/survey/survey_evaluations/add_condition_reference",
                               { item_id: evaluation_item, text: selected_val, level: item_level, object: item_object }
      );

    }

    if(!valid)
      alert('Invalid entry');

    return false

  });

  $('.survey_evaluations td.evaluation_title').live('click', function(){
    $('td.evaluation_title.selected').removeClass('selected');
    $(this).addClass('selected');
    $('body').append('<div id="edit_overlay" class="facebox_overlay">'+loader+'</div>');
    $.get( "/survey/survey_evaluations/get_evaluations", { set_id: $(this).attr('id') });
  });

  $('input.save_survey_evaluation').click(function(){
    $(this).parent().parent('form').find('.disabled input').attr('disabled', 'disabled');
  });

  $('.facebox').live('focus', function(){
    facebox_id = $(this).attr('id');
    form = $(this).find('form');

    if($(form).length > 0 && $(form).find('input[name=facebox_id]').length <= 0)
       $(form).append('<input type="hidden" name="facebox_id" value='+ facebox_id +'>');
  });

});

error = "";
function is_not_blank(ele) {
  if($(ele).val() == "")
    error += "* Field should not be blank. <br/>";
}

function is_number(ele) {
  if(! isFinite($(ele).val()))
    error += "* Value should be numeric. <br/>";
}

function range(ele, range_from, range_to) {
  text_length = $(ele).val().length;
  if(text_length < range_from || text_length > range_to)
    error += "* Value should range between " + range_from + " and " + range_to + ". <br/>";
}

function max_char(ele, size) {
  text_length = $(ele).val().length;
  if(text_length > size)
    error += "* Value should not exceed " + size + " characters. <br/>";
}

function equal_to(ele, comparison_text) {
  if($(ele).val() != comparison_text)
    error += "* Value should be '" + comparison_text + "'. <br/>";
}

function not_equal_to(ele, comparison_text) {
  if($(ele).val() == comparison_text)
    error += "* Value should not be '" + comparison_text + "'. <br/>";
}

function greater_than(ele, comparison_text) {
  if($(ele).val() <= comparison_text)
    error += "* Value should be greater than " + comparison_text + ". <br/>";
}

function greater_than_equal_to(ele, comparison_text) {
  if($(ele).val() < comparison_text)
    error += "* Value should be greater than or equal to " + comparison_text + ". <br/>";
}

function less_than(ele, comparison_text) {
  if($(ele).val() >= comparison_text)
    error += "* Value should be less than " + comparison_text + ". <br/>";
}

function less_than_equal_to(ele, comparison_text) {
  if($(ele).val() > comparison_text)
    error += "* Value should be less than or equal to " + comparison_text + ". <br/>";
}

function validate(ele) {
  if(error != "")
  {
    $(ele).css('border', '1px solid red');
    $(ele).addClass('disabled');
    $.facebox(error);
    $(ele).parent().next().find('button.evaluate_question').attr('disabled', 'disabled');
    $(ele).parent().addClass('disabled');
    error = "";
  }
  else
  {
    $(ele).css('border', '');
    $(ele).parent().removeClass('disabled');
  }
}