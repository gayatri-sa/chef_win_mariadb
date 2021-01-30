Imports System.Data
Imports System.Configuration
Imports MySql.Data.MySqlClient
Partial Class VB
    Inherits System.Web.UI.Page
    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not Me.IsPostBack Then
            Dim constr As String = ConfigurationManager.ConnectionStrings("constr").ConnectionString
            Using con As New MySqlConnection(constr)
                Using cmd As New MySqlCommand("SELECT * FROM Customers")
                    Using sda As New MySqlDataAdapter()
                        cmd.Connection = con
                        sda.SelectCommand = cmd
                        Using dt As New DataTable()
                            sda.Fill(dt)
                            GridView1.DataSource = dt
                            GridView1.DataBind()
                        End Using
                    End Using
                End Using
            End Using
        End If
    End Sub
End Class
