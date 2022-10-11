class CraqValidator
  attr_reader :errors

  ERROR_ANSWER_NOT_IN_LIST = 'has an answer that is not on the list of valid answers'
  ERROR_MISSING_ANSWER = 'was not answered'
  ERROR_ANSWERED_AFTER_TERMINAL_RESPONSE = 'was answered even though a previous response indicated that the questions were complete'

  def initialize(questions, answers)
    @questions = questions
    @answers = answers
    @errors = {}
  end

  def valid?
    terminal_response_found = false
    answers_found_after_terminal_response = false

    @questions.each_with_index do |question, index|
      answer_key = "q#{index}".to_sym

      if (@answers.nil? || (answer = validate_answer(@answers[answer_key])) == nil)
        if !terminal_response_found
          @errors[answer_key] = ERROR_MISSING_ANSWER
        end

        next
      end

      if answer < 0 || answer >= question[:options].length
        @errors[answer_key] = ERROR_ANSWER_NOT_IN_LIST
      else
        if terminal_response_found
          @errors[answer_key] = ERROR_ANSWERED_AFTER_TERMINAL_RESPONSE
          answers_found_after_terminal_response = true
        end

        if question[:options][answer][:complete_if_selected] == true
          terminal_response_found = true
        end
      end
    end

    terminal_response_found ? !answers_found_after_terminal_response :
     !(@errors.size > 0)
  end

  private

  # this method helps to validate that an answer is a valid integer or nil otherwise
  def validate_answer(value)
    Integer(value, exception: false)
  end
end