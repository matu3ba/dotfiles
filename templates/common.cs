// C/C++ to C# interop summary from https://mark-borg.github.io/blog/2017/interop/
// Interoperability mechanisms
// The .NET framework provides different ways of achieving interoperability. These are:
// - Platform Invocation (P/Invoke)
// - C++ Interop (implicit PInvoke)
// - COM Interop (exposing as COM objects)
// - Embedded Interop types (defining equivalence of types)
// Multiplatform: .NET Core

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

// SHENNANIGAN
// NET is C# with some different syntax to make stack and garbage collected
// heap explicit, which does not include memory managed by C and C++.

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


//if (sender is OpParamGridView)
//if (sender->GetType() == typeof(OpParamGridView))
//if (sender->GetType() == OpParamGridView)
//works: if (sender->GetType()->ToString() == "System::Windows::Forms::DataGridView")

// SHENNANIGAN .NET has no super or base to call virtual function of base classs
// This is wrong for .NET, but correct for C#
namespace WindowsForms_OverrideControl_DataGridView {
  public ref class CustomDataGridView : public System::Windows::Forms::DataGridView
  {
    // override must be placed after, in c# before function names
    bool ProcessDataGridViewKey(System::Windows::Forms::KeyEventArgs e) override
    {
      return super.ProcessDataGridViewKey(e);
    }
  };
}

// SHENNANIGAN Windows Forms
// Debugging callbacks handled elsewhere very annoying.
public ref class CustomDataGridView : public System::Windows::Forms::DataGridView
{
protected:
  bool ProcessDataGridViewKey(System::Windows::Forms::KeyEventArgs ^ e) override
  {
    if (e->KeyCode == System::Windows::Forms::Keys::Escape)
    {
      this->CancelEdit();
      return true;
    }
    return false;
  }
};