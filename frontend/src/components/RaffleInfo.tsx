import { useEntranceFee } from "@/hooks/useEntranceFee";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

export function RaffleInfo() {
  const { entranceFee, isLoading, error } = useEntranceFee();

  return (
    <Card className="w-full max-w-sm">
      <CardHeader>
        <CardTitle>Raffle Information</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="flex justify-between">
          <span className="text-muted-foreground">Entrance Fee</span>
          <span className="font-semibold">
            {isLoading && "Loading..."}
            {error && "Error loading fee"}
            {entranceFee && `${entranceFee} ETH`}
          </span>
        </div>
      </CardContent>
    </Card>
  );
}
