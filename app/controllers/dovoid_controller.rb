require 'cgi'
require 'profile'
require 'caller'
# Controller with actions for doing DoVoid API call. The name is chosen in consistent with other PayPal SDKs. 
class DovoidController < ApplicationController
	 
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
    @transaction_id = params[:authorization_id]  
  end

 # DoVoid API call
  def do_void     
    @caller =  PayPalSDKCallers::Caller.new(false)         
    @transaction = @caller.call(
      { :method          => 'DoVoid',
        :authorizationid => params[:authorization_id].to_s,
        :note            => params[:note].to_s,
        :trxtype         => 'V',
        :USER  =>  @@USER,
        :PWD   => @@PWD,
        :SIGNATURE => @@SIGNATURE,
        :SUBJECT => @@SUBJECT         
      }    
    )    
     
   if @transaction.success?  
      session[:void_response]=@transaction.response 
      redirect_to :controller => 'dovoid',:action => 'thanks'
    else
      session[:paypal_error]=@transaction.response
      redirect_to :controller => 'wppro', :action => 'error'
    end
  rescue Errno::ENOENT => exception
    flash[:error] = exception
    redirect_to :controller => 'wppro', :action => 'exception' 
  end     
  
  def thanks
	  @response = session[:void_response]
  end

end
