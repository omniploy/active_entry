require "active_entry/version"
require "active_entry/errors"
require "active_entry/controller_methods"
require "active_entry/railtie" if defined? Rails::Railtie

module ActiveEntry
  # Authenticates the user
  def authenticate!
    general_decision_maker_method_name = :authenticated?
    scoped_decision_maker_method_name = [action_name, :authenticated?].join("_").to_sym

    general_decision_maker_defined = respond_to? general_decision_maker_method_name, true
    scoped_decision_maker_defined = respond_to? scoped_decision_maker_method_name, true

    # Check if a scoped decision maker method is defined and use it over
    # general decision maker method.
    decision_maker_to_use = scoped_decision_maker_defined ? scoped_decision_maker_method_name : general_decision_maker_method_name

    # Raise an error if the #authenticate? action isn't defined.
    #
    # This ensures that you actually do authentication in your controller.
    if !scoped_decision_maker_defined && !general_decision_maker_defined 
      raise ActiveEntry::AuthenticationNotPerformedError
    end
    
    error = {}

    if method(decision_maker_to_use).arity > 0
      is_authenticated = send decision_maker_to_use, error
    else
      is_authenticated = send decision_maker_to_use
    end
    
    # If the authenticated? method returns not true
    # it raises the ActiveEntry::NotAuthenticatedError.
    #
    # Use the .rescue_from method from ActionController::Base
    # to catch the exception and show the user a proper error message.
    raise ActiveEntry::NotAuthenticatedError.new(error) unless is_authenticated == true
  end
  
  # Authorizes the user.
  def authorize!
    general_decision_maker_method_name = :authorized?
    scoped_decision_maker_method_name = [action_name, :authorized?].join("_").to_sym

    general_decision_maker_defined = respond_to? general_decision_maker_method_name, true
    scoped_decision_maker_defined = respond_to? scoped_decision_maker_method_name, true

    # Check if a scoped decision maker method is defined and use it over
    # general decision maker method.
    decision_maker_to_use = scoped_decision_maker_defined ? scoped_decision_maker_method_name : general_decision_maker_method_name

    # Raise an error if the #authorize? action isn't defined.
    #
    # This ensures that you actually do authorization in your controller. 
    if !scoped_decision_maker_defined && !general_decision_maker_defined 
      raise ActiveEntry::AuthorizationNotPerformedError
    end
    
    error = {}

    if method(decision_maker_to_use).arity > 0
      is_authorized = send(decision_maker_to_use, error)
    else
      is_authorized = send(decision_maker_to_use)
    end

    # If the authorized? method does not return true
    # it raises the ActiveEntry::NotAuthorizedError
    #
    # Use the .rescue_from method from ActionController::Base
    # to catch the exception and show the user a proper error message.
    raise ActiveEntry::NotAuthorizedError.new(error) unless is_authorized == true
  end
end
