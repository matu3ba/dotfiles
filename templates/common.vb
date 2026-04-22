Public Class Global_asax
  Inherits HttpApplication

  Private Shared _log As log4net.ILog = log4net.LogManager.GetLogger(Reflection.MethodBase.GetCurrentMethod().DeclaringType.ToString)
  Public Const ActivityKey As String = "OpenTelemetry.Activity"
  Private activitySource As ActivitySource =
    New ActivitySource(System.Configuration.ConfigurationManager.AppSettings("OTEL_SERVICE_NAME"))

  Sub Application_BeginRequest(ByVal sender As Object, ByVal e As EventArgs)
    Dim activity = activitySource.StartActivity(
      $"{HttpContext.Current.Request.HttpMethod} {HttpContext.Current.Request.Path}",
      ActivityKind.Server
    )
    If activity IsNot Nothing Then
      System.Diagnostics.Debug.Assert(activity.Id IsNot Nothing)

      activity.SetTag("http.method", Request.HttpMethod)
      activity.SetTag("http.url", Request.Url.ToString())
      activity.SetTag("http.target", Request.Path)
      activity.SetTag("http.host", Request.Url.Host)
      activity.SetTag("http.scheme", Request.Url.Scheme)
      activity.SetTag("http.user_agent", Request.UserAgent)
      If (HttpContext.Current.Request.UrlReferrer IsNot Nothing) Then
        activity.SetTag("http.referrer", Request.UrlReferrer.ToString());
      End If
      HttpContext.Current.Items(ActivityKey) = activity

      log4net.LogicalThreadContext.Properties("activityID") = activity.Id
      Dim _trace_id As String = activity.TraceId.ToString()
      log4net.LogicalThreadContext.Properties("cwSystemActivityID") = _trace_id
      HttpContext.Current.Items("cwSystemActivityID") = _trace_id
    End If

    Try
      _log.Info(String.Concat("BeginRequest-SOAPAction: ", HttpContext.Current.Request.Headers("SOAPAction")))
    Catch ex As Exception
      _log.Error("BeginRequest()", ex)
    End Try
  End Sub

  Private Sub Application_EndRequest(sender As Object, e As EventArgs)
    Dim activity As Activity = CType(HttpContext.Current.Items(ActivityKey), Activity)
    If activity IsNot Nothing Then
      activity.SetTag("http.status_code", HttpContext.Current.Response.StatusCode)
      If HttpContext.Current.Response.StatusCode >= 400 Then
        activity.SetStatus(ActivityStatusCode.Error)
      Else
        activity.SetStatus(ActivityStatusCode.Ok)
      End If
      activity.Stop()
    End If
  End Sub
End Class

' idea figure out how to do module for shared code
' broken:
' Public Module cwOTLP_ReqRespTracing
'     Public Const ActivityKey As String = "OpenTelemetry.Activity"
'     Private activitySource As ActivitySource =
'         new ActivitySource(System.Configuration.ConfigurationManager.AppSettings["OTEL_SERVICE_NAME"]);
'
'     Sub StartRequestSpan(http_context As HttpContext)
'          activity = activitySource.StartActivity($"{request.HttpMethod} {request.Path}", ActivityKind.Server);
'         http_context.Items(ActivityKey) = activity;
'     End Sub
'     Sub EndRequestSpan(http_context As HttpContext)
'         Dim activity as Activity = http_context.Items(ActivityKey)
'         if activity != null Then
'             var response = http_context.Response;
'             activity.Stop();
'         End If
'     End Sub
' End Module
