require 'cgi'
require 'profile'
require 'caller'
# Controller with actions for doing GetBalance API call. The name is chosen in consistent with other PayPal SDKs. 
class GetbalanceController < ApplicationController
	  
   # to make long names shorter for easier access and to improve readability define the following variables
    @@profile = PayPalSDKProfiles::Profile
    #unipay credentials hash
    @@email=@@profile.unipay
    # merchant credentials hash
    @@cre=@@profile.credentials
    
  #condition to check if 3 token credentials are passed
  if((@@email.nil?) && (@@cre.nil? == false))
      @@USER = @@cre["USER"]
      @@PWD = @@cre["PWD"]
      @@SIGNATURE  = @@cre["SIGNATURE"]
      @@SUBJECT = ""
  end
  #condition to check if UNIPAY credentials are passed
  if((@@cre.nil?) && (@@email.nil? == false) )
      @@USER = ""
      @@PWD = ""
      @@SIGNATURE  = ""
      @@SUBJECT = @@email["SUBJECT"]
  end
  #condition to check if 3rd party credentials are passed
  if((@@cre.nil? == false) && (@@email.nil? == false))  
      @@USER = @@cre["USER"]
      @@PWD = @@cre["PWD"]
      @@SIGNATURE  = @@cre["SIGNATURE"]
      @@SUBJECT = @@email["SUBJECT"]
    end  
    
  def get_input
	  reset_session
  end

# GetBalance API call  
  def get_balance    
    @caller =  PayPalSDKCallers::Caller.new(false)         
    @transaction = @caller.call(
      {
      :method          => 'GetBalance',
      :USER  =>  @@USER,
      :PWD   => @@PWD,
      :SIGNATURE => @@SIGNATURE,
      :SUBJECT => @@SUBJECT 
      }
    )    
     
   if @transaction.success?       
      session[:balance_response]=@transaction.response
      redirect_to :controller => 'getbalance',:action => 'thanks'
    else
      session[:paypal_error]=@transaction.response
      redirect_to :controller => 'wppro', :action => 'error'
    end
  rescue Errno::ENOENT => exception
    flash[:error] = exception
    redirect_to :controller => 'wppro', :action => 'exception'
  end    

  def thanks
    @response = session[:balance_response]
  end

end
