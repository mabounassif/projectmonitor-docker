class PulseMailer < ActionMailer::Base

  def red_over_one_day_notification(projects, options = {})
    from("Pivotal Pulse <devnull+pulse-ci@pivotallabs.com>")
    recipients(RED_NOTIFICATION_EMAILS)
    subject("Projects RED for over one day!")
    multipart("red_over_one_day_notification", :projects => projects)
  end
end
