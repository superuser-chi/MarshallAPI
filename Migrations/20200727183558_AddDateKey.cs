using Microsoft.EntityFrameworkCore.Migrations;

namespace MarshallAPI.Migrations
{
    public partial class AddDateKey : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "DateKey",
                table: "Days",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DateKey",
                table: "Days");
        }
    }
}
