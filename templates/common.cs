//==performance

// C/C++ to C# interop summary from https://mark-borg.github.io/blog/2017/interop/
// Interoperability mechanisms
// The .NET framework provides different ways of achieving interoperability. These are:
// - Platform Invocation (P/Invoke)
// - C++ Interop (implicit PInvoke)
// - COM Interop (exposing as COM objects)
// - Embedded Interop types (defining equivalence of types)
// - Tooling may break on non-windows line ending '\r\n'/'^M'
// Multiplatform: .NET Core
//
// https://learn.microsoft.com/en-us/dotnet/csharp/asynchronous-programming/
// https://devblogs.microsoft.com/dotnet/how-async-await-really-works/
// core drawback of async:
// * viral propagation: infects all using code
// * poor error handling
// * no explicit state machine
// * missing await runtime bug compiler only warns, not always picked up as warning
// * subsequent signals and events can be missed due to some missing special io cases

//==performance
// 8ns call overhead to ffi C code

// https://github.com/neogeek/csharp_editorconfig

// comptime https://github.com/sebastienros/comptime

// Still a problem: Very long build times for big code bases and unfinished (incremental) build system.

// SHENNANIGAN Windows Forms handle key combinations
// KeyPress event must be inherited by current window or dynamically set for all elements of a form
// https://learn.microsoft.com/en-us/dotnet/desktop/winforms/how-to-handle-user-input-events-in-windows-forms-controls?view=netframeworkdesktop-4.8
// protected override bool ProcessCmdKey(ref Message msg, Keys keyData) {
//   if (!this.ProcessKey(msg, keyData)) {
//      return base.ProcessCmdKey(ref msg, keyData);
//   }
//   return false;
// }
// protected virtual bool ProcessKey(Message msg, Keys keyData) {
//   //The condition needs to be either `if ((keyData & Keys.Enter) == keyData)` or `if (keyData == Keys.Enter)`.
//   if ((keyData & Keys.Enter) == Keys.Enter) {
//     Label1.Text = "Enter Key";
//     return true;
//   }
//   if ((keyData & Keys.Tab) == Keys.Tab) {
//     Label1.Text = "Tab Key";
//     return true;
//   }
//   return false;
// }

// https://learn.microsoft.com/de-de/dotnet/framework/interop/how-to-implement-callback-functions

// symbol packages (.snupkg) https://learn.microsoft.com/en-us/nuget/create-packages/symbol-packages-snupkg
// debugging nuget libs https://www.damirscorner.com/blog/posts/20250411-DebuggingLibrariesFromNuGet.html


// https://csharperimage.jeremylikness.com/2017/07/build-and-deploy-net-core-web-app-from.html
// https://andrewlock.net/building-net-framework-asp-net-core-apps-on-linux-using-mono-and-the-net-cli/

// SHENNANIGAN
// NET is C# with some different syntax to make stack and garbage collected
// heap explicit, which does not include memory managed by C and C++.

// https://www.red-gate.com/simple-talk/development/dotnet-development/routing-the-asp-net-way/
// Routing procedure [related to model view control(MVC)]
// ASP.NET Routing basically works in three steps:
//     Route definition: The route configuration is set in the application’s RouteConfig.cs (ASP.NET MVC) or Startup.cs (ASP.NET Core) file.
//     Route matching: The defined route pattern is matched against the incoming URL.
//     Route processing: The controller and action for the matching route are determined and the response is sent.
// https://medium.com/@ravitejherwatta/all-about-routing-in-asp-net-core-mvc-in-brief-51132a594a3b
// https://learn.microsoft.com/en-us/previous-versions/aspnet/cc668201(v=vs.100)
// https://medium.com/@thanuthana944/understanding-the-differences-controllerbase-vs-apicontroller-in-asp-net-4f2f51d94902

// https://www.c-sharpcorner.com/blogs/understanding-mvc-request-life-cycle-part-1
// New Project > ASP.NET Web Application > Add folders and core for MVC and select template
// Global.asax.cs
// 1 Model View Control (MVC) for ASP.NET and ASP.NET Core
// 2 MVC Basic Application setup and teardown
//   Routes need associated RouteHandler class. RouteHandler will provide ASP.NET
//   with HttpHandler to process incoming request after being matched to route.
//   Routes are registered via RouteTable inside app start event before other
//   life cycle events happen.
//
//   private void Application_Start() {
//     AreaRegistration.RegisterAllAreas();
//     FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
//     RouteConfig.RegisterRoutes(RouteTable.Routes);
//     BundleConfig.RegisterBundles(BundleTable.Bundles);
//   }
//   public static void RegisterRoutes(RouteCollection routes) {
//     routes.IgnoreRoute("{resource}.axd/{*pathInfo}");
//     routes.MapRoute(
//       name: "Default",url: "{controller}/{action}/{id}",
//       defaults: new { controller = "Home", action = "Index", id = UrlParameter.Optional } );
//     }
//   }
//   private void Application_End() { }
// 3 MVC Request life cycle
//   reqest > IIS > queued in app pool of app
//   app pool group of one or more URLs served by worker process
//   worker process (w3wp.exe) responsible to forward request to application
//   the request is processed by HttpApplication pipeline and events are fired in following order:
//   1  BeginRequest - first event in HTTP pipeline chain of execution when ASP.NET repsonds to request
//   * Always raised, always first on processing request
//   2  AuthenticateRequest - request authentication before processing attached module/event
//   3  PostAuthenticateRequest - after AuthenticateRequest event. info available in HttpContext
//   4  AuthorizeRequest - ASP.NET has authorized current request. perform custom authorization here.
//   5  PostAuthorizeRequest - user for current request has been authorized.
//   6  ResolveRequestCache - ASP.NET finishes authorization event to let caching modules serve requests from cache,
//      bypassing execution of event handler and calling EndRequest handlers.
//   7  PostResolveRequestCache – request can’t be served from cache, thus HTTP handler is created here. Page class gets
//      created if an aspx page is requested.
//   8  MapRequestHandler - MapRequestHandler event used by ASP.NET infra to determine request handler for current
//      request based on the file-name extension of requested resource.
//   9  PostMapRequestHandler - ASP.NET has mapped current request to appropriate HTTP handler
//   10 AcquireRequestState - ASP.NET acquires current state (for example, session state) that is associated with current request.
//      A valid session ID must exist.
//   11 PostAcquireRequestState - state information (for example, session state or application state) associated with current request was obtained.
//   12 PreRequestHandlerExecute - just before ASP.NET starts executing event handler.
//   13 ExecuteRequestHandler – when handler generates output. only event not exposed by HTTPApplication class.
//   14 PostRequestHandlerExecute - ASP.NET event handler has finished generating the output
//   15 ReleaseRequestState - after ASP.NET finishes executing all request event handlers. event signal ASP.NET state modules to
//      save current request state.
//   16 PostReleaseRequestState - ASP.NET has completed executing all request event handlers and request state data has
//      been persisted.
//   17 UpdateRequestCache - ASP.NET finishes executing an event handler in order to let caching modules store
//      responses that will be reused to serve identical requests from the cache.
//   18 PostUpdateRequestCache - When the PostUpdateRequestCache is raised, ASP.NET has completed processing code and
//      content of cache is finalized.
//   19 LogRequest - before ASP.NET writes/flushes log buffers (to actual writes into the backends),
//      content or loggers themself can be adjusted to allow very dynamic customization of the logs (or custom loggers).
//      This event is raised regardless of errors.
//   20 PostLogRequest - request has been logged
//   21 EndRequest - as the last event in the HTTP pipeline chain of execution when ASP.NET responds to a request.
//      In this event, you can compress or encrypt the response.
//   22 PreSendRequestHeaders – Fired after EndRequest if buffering is turned on (by default).
//      just before ASP.NET sends HTTP headers to the client.
//   23 PreSendRequestContent - just before ASP.NET sends content to the client.
//
//   Controller > Add > MVC 5 Controller - Empty > "HomeController"
// 4 MVC Life cycle idea

namespace IdleDetection {
  internal struct sLastInputInfo
  {
    public uint cbSize;
    public uint dwTime;
  }

  [System::Runtime::InteropServices::DllImport("User32.dll")]
  private static extern bool GetLastInputInfo(ref sLastInputInfo lastInputInfo);
  [System::Runtime::InteropServices::DllImport("Kernel32.dll")]
  private static extern uint GetLastError();

  public static uint GetIdleTime()
  {
    sLastInputInfo lastUserAction = new sLastInputInfo();
    // sLastInputInfo lastUserAction;
    lastUserAction.cbSize = (uint)Marshal.SizeOf(lastUserAction);
    GetLastInputInfo(ref lastUserAction);
    // GetLastInputInfo(&lastUserAction);
    return ((uint)System::Environment.TickCount - lastUserAction.dwTime);
  }

  public static long GetLastInputTime()
  {
    sLastInputInfo lastUserAction = new sLastInputInfo();
    lastUserAction.cbSize = (uint)Marshal.SizeOf(lastUserAction);
    if (!GetLastInputInfo(ref lastUserAction))
    {
        throw new System::Exception(GetLastError().ToString());
        // throw gnew System::Exception(GetLastError().ToString());
    }

    return lastUserAction.dwTime;
  }
}

namespace WindowsForms_TimerCallback {
  System::Windows::Forms::Timer^ m_Timer;
  int m_Interval = 20; // 20ms
  m_Timer = gcnew System::Windows::Forms::Timer();
  m_Timer->Tick += gcnew System::EventHandler(this, &ClassName::OnTimer);
  m_Timer->Interval = m_Interval;
  m_Timer->Enabled = true;
  m_Timer->Start();
}


//C#/.NET type checking
//if (sender is OpParamGridView)
//if (sender->GetType() == typeof(OpParamGridView))
//if (sender->GetType() == OpParamGridView)
//works: if (sender->GetType()->ToString() == "System::Windows::Forms::DataGridView")

// SHENNANIGAN .NET has no super or base to call virtual function of base classs
// This is wrong for .NET, but correct for C#

// .NET has : base() in constructor to inherit base class somehow
// https://www.devx.com/terms/base-class-net/
// unclear which version looks like at least it does not work with override

// SHENNANIGAN Windows Forms: There is no user accessible event log.
// Debugging callbacks handled elsewhere very annoying.

// You can override the Form.ProcessCmdKey method in order to be able to handle every key press of the user.
protected override bool ProcessCmdKey(ref Message msg, Keys keyData)
{
  if (keyData == Keys.Down || keyData == Keys.Up)
  {
    // Process keys
    return true;
  }

  return base.ProcessCmdKey(ref msg, keyData);
}

public ref class CustomDataGridView : public System::Windows::Forms::DataGridView
{
protected:
  // SHENNANIGAN On default ProcessDataGridViewKey one is never entered on
  // Escape keypress in contrast to ProcessDialogKey, because the superblock
  // Windows Forms Escape Handler runs.
  bool ProcessDataGridViewKey(System::Windows::Forms::KeyEventArgs ^ e) override
  {
    if (e->KeyCode == System::Windows::Forms::Keys::Escape)
    {
      this->CancelEdit();
      return true;
    }
    return false;
  }
  bool ProcessDialogKey(System::Windows::Forms::Keys keyData) override
  {
    // Extract the key code from the key value.
    System::Windows::Forms::Keys key = (keyData & System::Windows::Forms::Keys::KeyCode);
    if (key == System::Windows::Forms::Keys::Escape && this->IsCurrentCellInEditMode) {
      this->CancelEdit();
      this->EndEdit();
      return true;
    }
    return System::Windows::Forms::DataGridView::ProcessDialogKey(keyData);
  }
};

// https://stackoverflow.com/questions/16135490/visual-studio-2010-c-cli-in-static-library-mode-could-not-find-assembly-msco

// Basic Keypress event handler
CancelButton->KeyPress += gcnew System::Windows::Forms::KeyPressEventHandler(this, &KeypressNamespace::OnKeyPress);
System::Void KeypressNamespace::OnKeyPress(System::Object ^ sender, System::Windows::Forms::KeyPressEventArgs ^ e)
{
  auto sendername = sender->ToString();

  ContentPanel->Focus();
  if (e->KeyChar == 27)   //ESC-key
          CancelButton_Click(sender, e);
  // MS does not make overwriting some control characters easy, so we do not use tab key.
  //else if (e->KeyChar == 9)     //TAB-key
  //      TabButton_Click(sender, e);
  //else
  //{
  //      auto InputString = AppendCharacterToString(InputTextBox->Text, e->KeyChar);
  //      Update(InputString);
  //}
}

// .NET Framework, ASP.NET loki + tempo example under namespace 'AppFramework'
namespace AppFramework.AppName {
  public class WebApiApplication : System.Web.HttpApplication {
    private void Application_BeginRequest(object sender, EventArgs e)
    {
      var context = HttpContext.Current;
      // same as context.Items[ActivityKey] as Activity, activity != null
      if (context.Items[ActivityKey] is Activity activity)
      {
        Activity _act = context.Items[cwOTLP.ReqRespTracing.ActivityKey] as Activity;
        string _act_id = _act.Id;
        log4net.LogicalThreadContext.Properties["traceID"] = _act_id;
      }
    }
  }
}

namespace AppFramework.OTLP {
  public class WebApiApplication : System.Web.HttpApplication {
    private void Application_BeginRequest(object sender, EventArgs e)
    {
      // var sw = System.Diagnostics.Stopwatch.StartNew();
      // HttpContext.Current.Items["sw"] = sw;
      var context = HttpContext.Current;

      if (context.Items[ActivityKey] is Activity activity) // same as context.Items[ActivityKey] as Activity, activity != null
      {
        Activity _act = context.Items[cwOTLP.ReqRespTracing.ActivityKey] as Activity;
        string _act_id = _act.Id;
        log4net.LogicalThreadContext.Properties["traceID"] = _act_id;
      }
    }
  }

  public addAttributes()
  {
    string attributes = System.Configuration.ConfigurationManager.AppSettings["OTEL_RESOURCE_ATTRIBUTES"];
    if (!string.IsNullOrEmpty(attributes))
    {
       foreach (var attr in attributes.Split(','))
       {
           var parts = attr.Split('=');
           if (parts.Length == 2)
               resourceBuilder.AddAttributes(new[] { new KeyValuePair<string, object>(parts[0], parts[1]) });
       }
    }
  }
}

// see Systems.Diagnostics.DiagnosticSource
public partial class Activity : IDisposable
{
  public string? Id
  {
      get
      {
          // if we represented it as a traceId-spanId, convert it to a string.
          // We can do this concatenation with a stackalloced Span<char> if we actually used Id a lot.
          if (_id == null && _spanId != null)
          {
              // Convert flags to binary.
              Span<char> flagsChars = stackalloc char[2];
              HexConverter.ToCharsBuffer((byte)((~ActivityTraceFlagsIsSet) & _w3CIdFlags), flagsChars, 0, HexConverter.Casing.Lower);
              string id =
  #if NET
                  string.Create(null, stackalloc char[128], $"00-{_traceId}-{_spanId}-{flagsChars}");
  #else
                  "00-" + _traceId + "-" + _spanId + "-" + flagsChars.ToString();
  #endif
              Interlocked.CompareExchange(ref _id, id, null);

          }
          return _id;
      }
  }
}

namespace AppFramework.AppName {
}
