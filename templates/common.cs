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